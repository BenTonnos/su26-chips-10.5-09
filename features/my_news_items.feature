Feature: Search for news articles

  Scenario: Search for a news article with representative and issue selected
    Given a representative exists
    And I visit a representative's news items page
    When I follow "Add News Article"
    Then I should see "New news article"
    And I select a representative
    And I select an issue
    And I press "Search"
    Then I should see the selected representative link
    And I should see the selected issue

  Scenario: Search for news articles without selecting a representative or issue
    Given a representative exists
    And I visit a representative's news items page
    When I follow "Add News Article"
    Then I should see "New news article"
    And I press "Search"
    Then I should see "Representative: Not submitted"
    And I should see "Issue: Not submitted"


