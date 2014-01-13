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

  Scenario Outline: Video tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should match "<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'"

    Examples:
        | input                                        |
        | "http://www.youtube.com/watch?v=gokeLEC8dZc" |
        | "http://youtu.be/gokeLEC8dZc"                |
        | "YouTube http://youtu.be/gokeLEC8dZc inline test." |

  Scenario Outline: Magnet tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input                  | output                             |
        | "☎ +1(987)5554321"    | "<p><span class='phone'>☎ +1(987)5554321</span></p>" |
        | "✉ info_twitter.com"   | "<p><span class='email'>✉ info_twitter.com</span></p>" |
        | "✎ mudasobwa"          | "<p><span style='white-space: nowrap;'><a href='http://mudasobwa.livejournal.com/profile?mode=full'><img src='http://l-stat.livejournal.com/img/userinfo.gif' alt='[info]' style='border: 0pt none ; vertical-align: bottom; padding-right: 1px;' height='17' width='17'></a><a href='http://mudasobwa.livejournal.com/?style=mine'><b>mudasobwa</b></a></span></p>" |
        | "☇ id001"               | "<p><a name='id001'>​</a></p>" |

  Scenario Outline: Custom tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input                               | output                             |
        | "‒ Wikipedia, http://wikipedia.org" | "<p><br/> <small><a href='http://wikipedia.org'>Wikipedia</a></small></p>" |
        | "Wikipedia¹http://wikipedia.org"    | "<p><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia†Best knowledge base†"    | "<p><abbr title='Best knowledge base'>Wikipedia</abbr></p>" |
        | "Inplace picture¹http://mudasobwa.ru/images/am.jpg goes here." | "<p><img class='inplace' alt='Inplace picture' src='http://mudasobwa.ru/images/am.jpg'/> goes here.</p>" |
        | "http://mudasobwa.ru/images/am.jpg Standalone picture" | "<p><figure>␍  <img src='http://mudasobwa.ru/images/am.jpg'/>␍  <figcaption>␍    <p>␍      Standalone picture␍    </p>␍  </figcaption>␍</figure></p>" |

