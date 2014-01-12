# encoding: utf-8

Feature: Mapper-Ruler-Bowler abstraction produces valid bowlers

  Scenario: Bowler methods
    Given the input file is "config/bowlers/html.yaml"
    When bowler is created
    Then bowler has all the method aliases