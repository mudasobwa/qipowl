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

  Scenario Outline: Inplace tags nested
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should NOT equal to <output>

    Examples:
        | input                            | output                             |
        | "here ≡nested ≡bold≡ tags≡ go" | "<p>here <strong>nested <strong>bold</strong> tags</strong> goes</p>" |

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
    
    <pre class='ruby'>@mapping[:block] = ≡bold≡</pre>
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
        | "http://mudasobwa.ru/images/am.jpg Standalone picture" | " ␍ <figure> ␍   <img src='http://mudasobwa.ru/images/am.jpg'/> ␍   <figcaption> ␍     <p> ␍       Standalone picture ␍     </p> ␍   </figcaption> ␍ </figure> ␍ " |

  Scenario Outline: Markdown atavisms ⇒ links
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "Here ![Image](http://mudasobwa.ru/images/am.jpg) goes" | "<p>Here <img class='inplace' alt='Image' src='http://mudasobwa.ru/images/am.jpg'/> goes</p>" |
        | "![Figure](http://mudasobwa.ru/images/am.jpg)" | " ␍ <figure> ␍   <img src='http://mudasobwa.ru/images/am.jpg'/> ␍   <figcaption> ␍     <p> ␍       Figure ␍     </p> ␍   </figcaption> ␍ </figure> ␍ " |
        | "Here [Link](http://wikipedia.org/) goes" | "<p>Here <a href='http://wikipedia.org/'>Link</a> goes</p>" |
        | "Here *italic* goes" | "<p>Here <em>italic</em> goes</p>" |
        | "Here inplace*it*alic goes" | "<p>Here inplace<em>it</em>alic goes</p>" |
        | "Here non-italic 5*3 math goes" | "<p>Here non-italic 5*3 math goes</p>" |
        | "Here **bold** goes" | "<p>Here <strong>bold</strong> goes</p>" |
        | "Here ~~del~~ goes" | "<p>Here <del>del</del> goes</p>" |
        | "Here `code` goes" | "<p>Here <code>code</code> goes</p>" |


  Scenario Outline: Regular tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "List: • li1 • li2" | "<p>List:</p> <ul class='fancy'><li>li1 </li> <li>li2</li></ul>" |
        | "List: • li1  • nested 1  • nested 2 • li2" | "<p>List:</p> <ul class='fancy'><li>li1 </li> <ul class='fancy'><li>nested 1 </li> <li>nested 2  </li></ul> <li>li2</li></ul>" |
        | "Data: ▶ dt — dd ▶ dt — dd" | "<p>Data:</p> <dl> ␍ <dt>dt</dt> ␍ <dd>dd </dd> ␍   ␍ <dt>dt</dt> ␍ <dd>dd</dd> ␍ </dl>" |
        | "§1 Header" | "<h1>Header</h1>" |
        | "〉 Blockquote" | "<blockquote><p class='blockquote'>Blockquote</p></blockquote>" |
        
  Scenario Outline: Self tags
    Given we use "html" bowler
    When the input string is <input>
    And the execute method is called on bowler
    Then the result should equal to <output>

    Examples:
        | input                | output                                         |
        | "here qipowl goes"   | "<p>here <strong><a href='http://qipowl.github.com'>qipowl</a></strong> goes</p>"     |
        | "here tag goes"      | "<p>here <a href='/tags/tag'>tag</a> goes</p>" |
        | "here tag2 goes"     | "<p>here <b><a href='/tags/tag2'>tag2</a></b> goes</p>" |
        | "here tag3 goes"     | "<p>here <b><a href='/tags/tag3'>tag3</a></b> goes</p>" |

  Scenario: Address tag
    Given we use "html" bowler
    When the input string is "℁  ≡Twitter≡ ⏎  ☎ +1(987)5554321 ⏎  ✉ info@twitter.com"
    And the execute method is called on bowler
    Then the result should equal to "<address><strong>Twitter</strong> <br/> <span class='phone'>☎ +1(987)5554321</span> <br/> <span class='email'>✉ info@twitter.com</span></address>"

  Scenario: Entity addition
    Given we use "html" bowler
    When the input string is "List: × li1 line item × li2"
    And rule "×" is added to mapping as "li" in "regular" section with "ol" enclosure
    And the execute method is called on bowler
    Then the result should equal to "<p>List:</p> <ol><li>li1 line item </li> <li>li2</li></ol>"

  Scenario: Entity removal
    Given we use "html" bowler
    When the input string is "List: ◦ li1 ◦ li2"
    And rule "◦" is removed from mapping
    And the execute method is called on bowler
    Then the result should equal to "<p>List: ◦ li1 ◦ li2</p>"

  Scenario: Standalone images
    Given we use "html" bowler
    When the input string is
      """
      ✍
      Preamble: given
      ✍
      
      〉 http://mudasobwa.ru/i/self.jpg With caption
        ‒ Wiki, http://wikipedia.ru
      
      Nice?
      """
    And the execute method is called on bowler
    Then the result should equal to
    """
    
    
    <blockquote><p class='blockquote'>http://mudasobwa.ru/i/self.jpg With caption
    <br/> <small><a href='http://wikipedia.ru'>Wiki</a></small> </p></blockquote>
    <p>Nice?</p>
    """

  Scenario: Comments
    Given we use "html" bowler
    When the input string is
      """
      ---
      This is a comment text
      ---
      
      Nice?
      """
    And the execute method is called on bowler
    Then the result should equal to
    """
    
    <p>Nice?</p>
    """

  Scenario: Blockquotes
    Given we use "html" bowler
    When the input string is
    """
    §2 Blockquotes
    
    〉 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere
    erat a ante.
       〉 Nested blockquote first line
     〉 Nested blockquote second line
    〉 Lorem ipsum para text 2.
    
    Some para text.
    
    〉 Intro 1.
     • list item ≡with bold≡ 1
     • list item ≈emphasized≈ 
      • nested list item 1
      • nested list item 2 
    
    〉 Blockquote standalone.
    
    〉 Intro 2.
     • list item 2.1 
     • list item 2.2
    〉 Continuing intro 2.
    
    Blockquote standalone.
    """
    And the execute method is called on bowler
    Then the result should match "<blockquote><blockquote><blockquote><p class='blockquote'>Nested blockquote first"
    And the result should match "</li> <ul class='fancy'><li>nested list item 1"
    And the result should match "<p>Blockquote standalone.</p>"

