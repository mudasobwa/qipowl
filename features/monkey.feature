# encoding: utf-8

Feature: String improvements

  Scenario: I18n of up-/down-case and capitalize
    Given input string is "мама"
    When I call upcase on it
    Then the result should equal to "МАМА"
