# encoding: utf-8

Feature: Composer for HTML produces HTML

  Scenario Outline: Inline tags
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                  | output                             |
        | "here ≈italic≈ goes"   | "<p class='dropcap'>here <em>italic</em> goes</p>" |
        | "here ≡bold≡ goes"     | "<p class='dropcap'>here <strong>bold</strong> goes</p>" |
        | "here ↓small↓ goes"    | "<p class='dropcap'>here <small>small</small> goes</p>" |
        | "here λcodeλ goes"     | "<p class='dropcap'>here <code>code</code> goes</p>" |
        | "here ≡λbold codeλ≡ goes" | "<p class='dropcap'>here <strong><code>bold code</code></strong> goes</p>" |
        | "here λ≡code bold≡λ goes" | "<p class='dropcap'>here <code><strong>code bold</strong></code> goes</p>" |
        | "Hello, ≈World≈!"   | "<p class='dropcap'>Hello, <em>World</em>!</p>" |

  Scenario Outline: Syntactic sugar
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                  | output                             |
        | "— Wikipedia, http://wikipedia.org" | "<p class='dropcap'><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia¹http://wikipedia.org" | "<p class='dropcap'><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia†Best knowledge base†" | "<p class='dropcap'><abbr title='Best knowledge base'>Wikipedia</abbr></p>" |

  Scenario Outline: Magnets
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                  | output                             |
        | "☎ +1(987)5554321"     | "<p class='dropcap'><span class='phone'>☎ +1(987)5554321</span></p>" |
        | "✉ info_twitter.com"   | "<p class='dropcap'><span class='email'>✉ info_twitter.com</span></p>" |

  Scenario Outline: Flushes (oneliners)
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input     | output                             |
        | "A ⏎ B"   | "<p class='dropcap'>A <br> B</p>"  |

  Scenario Outline: Flushes (multiliners)
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should be multiline and almost equal to <output>

    Examples:
        | input     | output                             |
        | "A —— B"  | "<p class='dropcap'>A</p><hr><p class='dropcap'>B</p>" |

  Scenario Outline: Linewides
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should be multiline and almost equal to <output>

    Examples:
        | input               | output                             |
        | "List: • li1 • li2" | "<p class='dropcap'>List:</p><ul><li>li1</li><li>li2</li></ul>" |
        | "Data: ▶ dt — dd ▶ dt — dd" | "<p class='dropcap'>Data:</p><dl><dt>dt</dt><dd>dd</dd><dt>dt</dt><dd> dd</dd></dl>" |

  Scenario Outline: Customs
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "Here ghgh goes" | "<p class='dropcap'>Here <a class='tag'>ghgh</a> goes</p>" |

  Scenario Outline: Markdown atavisms ⇒ links
    Given the input string is <input>
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "Here ![Image](http://wikipedia.org/a.png) goes" | "<p class='dropcap'>Here <a href='http://wikipedia.org/a.png'>Image</a> goes</p>" |
        | "Here [Link](http://wikipedia.org/) goes" | "<p class='dropcap'>Here <a href='http://wikipedia.org/'>Link</a> goes</p>" |

  Scenario: Full processing
    Given the input string is taken from file "spec/input.tgm"
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to content of file "spec/output.html"

    

