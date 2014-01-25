# encoding: utf-8

Feature: Mapper-Ruler-Bowler abstraction produces valid bowlers

  Scenario: Bowler methods
    Given we use "html" bowler
    When the input string is ""
    Then bowler has all the method aliases

  Scenario: Config params set properly
    Given nothing
    When we request param "bowlers"
    Then param value ends with "/qipowl/config/bowlers"

  Scenario: Additional map mergeg properly
    Given we add additional bowler directory "spec"
    And we use "html" bowler with additional map "html_additional_test"
    When the input string is "This is ⌚striked⌚ out."
    And the execute method is called on bowler
    Then the result should equal to "<p>This is <del>striked</del> out.</p>"


