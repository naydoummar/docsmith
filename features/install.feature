Feature: docsmith install build
  As a user of docsmith
  I want to change the build component
  So that I use more customised workflows and advanced features

  Scenario: Starting from scratch
    When I run "docsmith init"
    Then I should have a ".travis.yml" file
    And I should have a "Gemfile" file with "github-pages"
    And I should have a "Gemfile" file without "rake"
    And I should not have a "Rakefile" file

  Scenario: Starting from scratch and running docsmith install integration
    When I run "docsmith init"
    And I run "docsmith install --test integration"
    Then I should see "No integration plugin currently installed."

  Scenario: Starting from scratch and running docsmith install integration travis
    When I run "docsmith init"
    And I run "docsmith install --test integration travis"
    Then I should have a ".travis.yml" file
    And I should have a "Gemfile" file with "github-pages"
    And I should have a "package.json" file
    And I run "pjv -wr" I should see "valid: true" 

  # Should fail with 'Can't figure out GitHub repo name'

  # TODO:
  #   Test for Travis repository not known to https://api.travis-ci.org/: contentascode/docsmith-init
  #   Test for gh-pages branch not being created yet error: pathspec 'gh-pages' did not match any file(s) known to git.

  Scenario: Starting with a github-pages build
    Given I clone the contentascode "fixture/build-github-pages" branch
    When I run "docsmith install --test integration"
    Then I should see "No integration plugin currently installed."
    And I should have a "Gemfile" file with "github-pages"
    And I should not have a ".travis.yml" file
    And I should not have a "package.json" file

  Scenario: Changing from a github-pages build to a travis build
    Given I clone the contentascode "fixture/build-github-pages" branch
    When I run "docsmith install --test integration travis"
    Then I should have a "Gemfile" file with "github-pages"
    # And I should have a "Gemfile" file without "~> 15" # github-pages shoudn't be pinned
    # And I should have a "Gemfile" file without "rake"
    And I should have a ".travis.yml" file
    And I should have a "package.json" file
    And I run "pjv -wr" I should see "valid: true" 
    # TODO Set environment variables and test _config.yml
