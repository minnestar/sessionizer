Feature: Managing Sessions

  @javascript
  Scenario: As a guest user, I want to suggest a session
    Given an upcoming event
    And I add a new Development session about RoR
    Then the new session should show up in the session list

  Scenario: As a guest user, I want to mark interest to a session
    Given an upcoming event
    And I browse the sessions
    When I indicate that I might attend a session
    Then I should be added to the participant list of that session

    

