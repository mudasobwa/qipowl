# encoding: utf-8

Feature: Mapper-Ruler-Bowler abstraction produces valid bowlers

  Scenario: Bowler methods
    Given the input file is "config/bowlers/html.yaml"
    When bowler is created
    Then bowler has all the method aliases
    
  Scenario: Bowler execution
    Given the input file is "config/bowlers/html.yaml"
    When bowler is created
    And the input string is "Hello, ≡world≡!"
    And the execute method is called on bowler
    Then the output is "Hello, world!"