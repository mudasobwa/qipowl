# encoding: utf-8

Feature: Text must be properly translated with Ispru

  Scenario Outline: Russian language
    Given we use "ispru" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input                          | output                                  |
        | "Он сказал: 'Поехали!'."       | "Он сказал: «Поехали!»."                |
        | "Ссылка: http://wikipedia.org не покорежена." | "Ссылка: http://wikipedia.org не покорежена." |
        | "Mamá lavados marco."          | "Мама моет раму." |
