# encoding: utf-8

Feature: All the possibilities of HTML parser

  Scenario Outline: Inplace tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "here ≈italic≈ goes"           | "<p>here <em>italic</em> goes</p>" |
        | "here ≡bold≡ goes"            | "<p>here <strong>bold</strong> goes</p>" |
        | "here ↓small↓ goes"           | "<p>here <small>small</small> goes</p>" |
        | "here ↑sup↑ goes"             | "<p>here <sup>sup</sup> goes</p>" |
        | "here abbr†desc ription† goes" | "<p>here <abbr title='desc ription'>abbr</abbr> goes</p>" |
        | "here ✁del✁ goes"             | "<p>here <del>del</del> goes</p>" |
        | "here ✿_span_nobrnobr✿_span_nobr goes" | "<p>here <nobr>nobr</nobr> goes</p>" |
        | "here ÷deleted÷ goes"          | "<p>here <del>deleted</del> goes</p>" |
        | "here λcodeλ goes"             | "<p>here <code>code</code> goes</p>" |
        | "here ≡λbold codeλ≡ goes"     | "<p>here <strong><code>bold code</code></strong> goes</p>" |
        | "here λ≡code bold≡λ goes"     | "<p>here <code><strong>code bold</strong></code> goes</p>" |
        | "Hello, ≈World≈!"              | "<p>Hello, <em>World</em>!</p>" |


  Scenario Outline: Alone tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input     | output                    |
        | "A ⏎ B"   | "<p>A <br/> B</p>"        |
        | "A —— B"  | "<p>A</p> <hr/> <p>B</p>" |

  Scenario: Block tag Λ
    Given we use "html" bowler
    When the input string is "Λ ruby @mapping[:block] = ≡bold≡ Λ"
    And the execute method is called on bowler
    Then the result should equal to
    """
    
    <pre class='ruby'>@mapping[:block] = ≡bold≡ </pre>
    """

  Scenario: Block tag ✍
    Given we use "html" bowler
    When the input string is
    """
    ✍
      ruby @mapping[:block] = ≡bold≡
    ✍
    """
    And the execute method is called on bowler
    Then the result should equal to
    """


    """
