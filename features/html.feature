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
        | "— Wikipedia, http://wikipedia.org" | "<p class='dropcap'><small><a href='http://wikipedia.org'>Wikipedia</a></small></p>" |
        | "Wikipedia¹http://wikipedia.org" | "<p class='dropcap'><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia†Best knowledge base†" | "<p class='dropcap'><abbr title='Best knowledge base'>Wikipedia</abbr></p>" |
        | "Inplace picture¹http://mudasobwa.ru/images/am.jpg goes here." | "<p class='dropcap'><img alt='Inplace picture' src='http://mudasobwa.ru/images/am.jpg'> goes here.</p>" |
        | "http://mudasobwa.ru/images/am.jpg Standalone picture" | "<figure><img src='http://mudasobwa.ru/images/am.jpg'><figcaption><p>Standalone picture</p></figcaption></figure>" |

  Scenario Outline: Syntactic sugar with carriage returns
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should start with to <output>

    Examples:
        | input                  | output                             |
        | "http://www.youtube.com/watch?v=gokeLEC8dZc" | "<iframe width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "http://youtu.be/gokeLEC8dZc" | "<iframe width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "YouTube http://youtu.be/gokeLEC8dZc inline test." | "<iframe width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |

  Scenario: Address
    Given the input string is "℁  ≡Twitter≡ ⏎  ☎ +1(987)5554321 ⏎  ✉ info@twitter.com"
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to "<address><strong>Twitter</strong> <br> <span class='phone'>☎ +1(987)5554321</span> <br> <span class='email'>✉ info@twitter.com</span></address>"
  
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
        | "§1 Header" | "<h1>Header</h1>" |

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
        | "Here ![Image](http://mudasobwa.ru/images/am.jpg) goes" | "<p class='dropcap'>Here <img alt='Image' src='http://mudasobwa.ru/images/am.jpg'> goes</p>" |
        | "![Figure](http://mudasobwa.ru/images/am.jpg)" | "<figure><img src='http://mudasobwa.ru/images/am.jpg'><figcaption><p>Figure</p></figcaption></figure>" |
        | "Here [Link](http://wikipedia.org/) goes" | "<p class='dropcap'>Here <a href='http://wikipedia.org/'>Link</a> goes</p>" |

  Scenario: Full processing
    Given the input string is taken from file "spec/full_input.tgm"
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to content of file "spec/output.html"

  Scenario: Weird behaviour with words starting with “ni”
    Given the input string is "Very define and defined and even defined? words"
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to "<p class='dropcap'>Very define and defined and even defined? words</p>"

#  Scenario: HTML ⇒ TG
#    Given the input string is taken from file "spec/output.html"
#    And parser is "html"
#    When input string is reversed with unparse_and_roll
#    Then the result should equal to content of file "spec/input.tgm"

