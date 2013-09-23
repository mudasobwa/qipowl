# encoding: utf-8

Feature: Typogrowl markup is translated to almost (:-)) well-formed DSL
  In order to make a markdown-like documents more readable
  I want to use unicode bullets and ruby DSL to produce correct output (it’s 2013, huh)

  Scenario: brackets should be substituted before processing
    Given the input string is "Hello, (World)!"
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to "Hello, ≺World≻!"
    And no parenthesis are left in the input

  Scenario Outline: tags from `surroundings` group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "Hello, ≈World≈!"              | "Hello, ≈( ' World ' )!"           |
        | "Hello, ≡World≡!"              | "Hello, ≡( ' World ' )!"           |
        | "Hello, ↓World↓!"              | "Hello, ↓( ' World ' )!"           |
        | "Hello, λWorldλ!"              | "Hello, λ( ' World ' )!"           |
        | "↓World, ≡I like≡ you↓!"       | "↓( ' World, ≡( ' I like ' ) you ' )!" |

  Scenario Outline: tags from `all_sufficient` group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "Hello —— World!"              | "Hello ——() World!"                |
        | "Hello,⏎World!"                | "Hello,⏎()World!"                  |

  Scenario Outline: handy human-readable tags
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "— Wikipedia, http://wikipedia.org" | "¹( ' Wikipedia ', ' ⚓('http://wikipedia.org') ' )" |
        | "— Wikipedia, Main, http://wikipedia.org" | "¹( ' Wikipedia, Main ', ' ⚓('http://wikipedia.org') ' )" |
        | "— Wikipedia Main http://wikipedia.org" | "— Wikipedia Main ⚓('http://wikipedia.org')" |

  Scenario Outline: tags from `till_space` group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                       | output                             |
        | "☎ (123) 456-7890"          | "☎( ' ≺123≻ 456-7890 ' )"          |
        | "✉ first.last@example.com"  | "✉( ' first.last@example.com ' )"  |

  Scenario Outline: anchor tags with determined content type
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                  | output                                     |
        | "http://wikipedia.org" | "⚓('http://wikipedia.org')"                |
        | "http://stackoverflow.com/content/img/5th-anniversary-banner.png" | "⚐('http://stackoverflow.com/content/img/5th-anniversary-banner.png')" |
        | "http://www.youtube.com/watch?v=Ki6rcXvUWP0" | "✇('http://www.youtube.com/watch?v=Ki6rcXvUWP0')" |
        | "http://youtu.be/Ki6rcXvUWP0" | "✇('http://youtu.be/Ki6rcXvUWP0')" |

  Scenario Outline: tags from `sprawling` group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                                 | output                      |
        | "From Wikipedia¹http://wikipedia.org" | "From ¹( ' Wikipedia ', ' ⚓('http://wikipedia.org') ' )" |
        | "From Wikipedia†Best Knowledge Base†" | "From †( ' Wikipedia ', ' Best Knowledge Base ' )" |

  Scenario: tags from `nested` and `block` groups
    Given the input string is taken from file "data/nested.tg"
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to content of file "data/precompiled/nested.tgp"

  Scenario Outline: tags from `till_eol` group
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                   | output                                    |
        | "§1 Heading 1"          | "§1( '  Heading 1 ' )"                    |
        | "§2 Heading 2"          | "§2( '  Heading 2 ' )"                    |
        | "§ § Heading 2"         | "§ §( '  Heading 2 ' )"                   |
        | "§3 Heading 3"          | "§3( '  Heading 3 ' )"                    |
        | "§4 Heading 4"          | "§4( '  Heading 4 ' )"                    |
        | "§5 Heading 5"          | "§5( '  Heading 5 ' )"                    |
        | "§6 Heading 6"          | "§6( '  Heading 6 ' )"                    |
        | "▶ Desc list — A desc"  | "▶( '  Desc list — A desc ' )"            |
        | "✎ Comment"             | "✎( '  Comment ' )"                       |
        | "☆ Fusce dapibus"       | "☆( '  Fusce dapibus ' )"                 |
        | "★ Nullam id dolor"     | "★( '  Nullam id dolor ' )"               |
        | "☛ Duis mollis"         | "☛( '  Duis mollis ' )"                   |
        | "☞ Maecenas sed"        | "☞( '  Maecenas sed ' )"                  |
        | "☣ Etiam porta"         | "☣( '  Etiam porta ' )"                   |
        | "☢ Donec ullamcorper"   | "☢( '  Donec ullamcorper ' )"             |

  Scenario Outline: tags mixture
    Given the input string is <input>
    When input string is processed with Typogrowl’s preliminary parser
    Then the result should equal to <output>

    Examples:
        | input                | output                                       |
        | "§1 Hello, ≈World≈!" | "§1( '  Hello, ≈( ' World ' )! ' )"          |
        | "▶ Hello — ≡World!≡" | "▶( '  Hello — ≡( ' World! ' ) ' )"          |
        | "✎ Hello¹World" | "✎( '  ¹( ' Hello ', ' World ' ) ' )"             |
        | "✎ Hello†≡World≡†" | "✎( '  †( ' Hello ', ' ≡( ' World ' ) ' ) ' )" |

