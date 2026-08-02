Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

@javascript
Scenario: Displaying counties on a state map
Given I am on the state page for "CA"
Then I should see 58 counties

Scenario: Viewing representatives from a county search
Given I am on the state page for "CA"
When I click the county "Alameda County"
Then I should see representative results
  	
