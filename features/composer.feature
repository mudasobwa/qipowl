# encoding: utf-8

Feature: Composer for HTML produces HTML

  Scenario: Known well-formed tg file
    Given the input string is taken from file "data/current.tg"
    When input string is processed with Typogrowl’s preliminary parser
    And preliminary parsed string is processed with Typogrowl’s HTML composer
    Then the result should be printed out
#    Then the result should equal to content of file "data/precompiled/current.tgp"
   