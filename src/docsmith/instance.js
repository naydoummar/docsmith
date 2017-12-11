const debug = require('debug')('docsmith:instance');
const fs = require('fs-extra');
const path = require('path');

const yaml = require('js-yaml').safeLoad;
const read = require('fs').readFileSync;

global.Promise = require('bluebird');

global.Promise.promisifyAll(fs);

const settings = require('./utils/settings');
const { exit } = require('./utils/terminal');
const { doInfo } = require('./utils/git');
const { doListGlobal } = require('./utils/npm');

const doInstancesInfo = async ({ instances }) => {
  debug('instances', instances);
  return Promise.all(
    Object.keys(instances).map(async instance => {
      debug('pkg', instances[instance].package);
      const { path: pth, link, version, name, description } = await doListGlobal(instances[instance].package);
      debug('path', pth);
      debug('link', link);
      // Gather the content of the content.yml.
      const content = yaml(read(path.join(pth, './content.yml'), 'utf8'));

      // Lookup package content.yml
      const pkgs = Object.keys(content.packages)
        .map(pkg => ({
          [pkg]: {
            package: content.packages[pkg],
            ...(fs.existsSync(path.join(settings.packages, pkg, './content.yml'))
              ? {
                  status: 'installed',
                  install: path.join(settings.packages, pkg),
                  ...yaml(read(path.join(settings.packages, pkg, './content.yml'), 'utf8'))
                }
              : { status: 'uninstalled' })
          }
        }))
        .reduce((acc, cur) => ({ ...acc, ...cur }), {});
      debug('pkgs', pkgs);

      return {
        instance,
        package: instances[instance].package,
        name: description,
        version,
        path: pth,
        link,
        content: { ...content, packages: pkgs }
      };
    })
  ).then(pkgs => pkgs.reduce((acc, { instance, ...cur }) => ({ ...acc, [instance]: cur }), {}));
  // .then(see => console.log('see', see));
};

export { doInstancesInfo };