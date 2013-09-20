Feature: Typogrowl markup is translated to almost (:-)) well-formed DSL
  In order to make a markdown-like documents more readable
  I want to use unicode bullets and ruby DSL to produce correct output (it’s 2013, huh)

  Scenario Outline: Simple markup: tags from surroundings group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "Hello, ≈World≈!"              | "Hello, ≈( ' World ' )!"           |
        | "Hello, ≡World≡!"              | "Hello, ≡( ' World ' )!"           |
        | "Hello, ↓World↓!"              | "Hello, ↓( ' World ' )!"           |
        | "↓World, ≡I like≡ you↓!"       | "↓( ' World, ≡( ' I like ' ) you ' )!" |

