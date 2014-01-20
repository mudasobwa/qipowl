# encoding: utf-8

Feature: Mapper-Ruler-Bowler abstraction produces valid bowlers

  Scenario: Bowler methods
    Given we use "html" bowler
    When the input string is ""
    Then bowler has all the method aliases
