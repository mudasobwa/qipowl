Feature: Typogrowl input should be properly split into lines
   In order make the parsing and HTML generation available
   I want the input was splitted corectly

  Scenario: Para input should be splitted properly into block elements
    Given the input is taken from file "para.tg"
    When we split the input
    Then the result is array of size "5"
    And the first item equals to "§ h1. Heading"

  Scenario: Blockqoutes input should be splitted properly into block elements
    Given the input is taken from file "blockquote.tg"
    When we split the input
    Then the result is array of size "8"
    And the first item equals to "§ Blockquotes"

  Scenario: Addresses input should be splitted properly into block elements
    Given the input is taken from file "address.tg"
    When we split the input
    And we parse "2" item with “block” function
    Then the result is array of size "2"
    And the first item equals to "✎ Addresses"
    And the result starts with "<address><strong>Twitter, Inc.</strong>"

  Scenario: Nested blockqoutes input should be splitted properly
    Given the input is taken from file "blockquote.tg"
    When we split the input
    Then the result is array of size "8"
    And the first item equals to "§ Blockquotes"

  Scenario: Para block should be parsed properly
    Given the input is taken from file "para.tg"
    When we split the input
    And we parse last item with “block” function
    Then the result starts with "<p>Maecenas sed diam eget risus"
    And the result ends with "</p>"

  Scenario: Paragraph block with inlines should be parsed properly
    Given the input is taken from file "para.tg"
    When we split the input
    And we parse "3" item with “block” function
    Then the result starts with "<p class='lead'>Nullam quis risus eget urna mollis ornare vel eu leo. Cum"
    And the result ends with "</p>"

  Scenario: Blockquote block should be parsed properly
    Given the input is taken from file "blockquote.tg"
    When we split the input
    And we parse last item with “block” function
    Then the result starts with "<blockquote>and, finally, the pure blockquote item</blockquo"
    And the result ends with "the pure blockquote item</blockquote>"

  Scenario: Blockquote block with inlines should be parsed properly
    Given the input is taken from file "blockquote.tg"
    When we split the input
    And we parse "3" item with “block” function
    Then the result starts with "<blockquote>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante. <blockqu"
    And the result ends with "f='http://localhost'>anchor</a></blockquote>"

  Scenario: Example file should be parsed properly
    Given the input is taken from file "current.tg"
    When we process the input
    Then the result is printed out

