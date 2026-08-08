Feature: Accessibility
    So that all users can use our app, and we do not get sued,
    all pages should meet full accessibility standards.

# Accessibility Testing Relies on a Gem Called 'axe'
# axe uses JavaScript to audit pages for compliance with web standards.
# See https://github.com/dequelabs/axe-core-gems/blob/develop/packages/axe-core-cucumber/README.md

## These tests are excluded by default when running cucumber (see config/cucumber.yml)
#  Run cucumber -p a11y to run the 'a11y' profile

@a11y
Scenario: The Homepage
    Given I am on the homepage
    Then the page should be axe clean

@a11y
Scenario: The Login Page
    Given I am on the login page
    # e.g. enable steps like this for debugging.
    # Then show me the page
    Then the page should be axe clean

@a11y
Scenario: The Representatives Page
    Given I am on the representatives page
    Then the page should be axe clean

## CHIPS 10.5 -- add iteration 1/2 additional pages here.
## You may want to set up conditions like searching for data, etc.


@a11y
Scenario: The State Map Page
    Given I am on the state page for "CA"
    Then I should see "California"
    And the page should be axe clean

@a11y
Scenario: The search Representative's page 
    Given I am on the representatives page
    When I search for zipcode "94706"
    And I press "Search"
    Then I should see representative results
    And the page should be axe clean

@a11y
Scenario: The New News Article Page
    Given a representative exists
    And I visit a representative's news items page
    When I follow "Add News Article"
    Then I should see "New news article"
    And the page should be axe clean

@a11y
Scenario: The News Article Search Page
    Given a representative exists
    And I visit a representative's news items page
    When I follow "Add News Article"
    And I select a representative
    And I select an issue
    And I press "Search"
    Then I should see the selected issue
    And the page should be axe clean
