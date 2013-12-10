# encoding: utf-8

Feature: Composer for HTML produces HTML

  Scenario Outline: Inplace tags
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                          | output                             |
        | "here ≈italic≈ goes"           | "<p class='owl'>here␍  <em>italic</em>␍  goes</p>" |
        | "here ≡bold≡ goes"            | "<p class='owl'>here␍  <strong>bold</strong>␍  goes</p>" |
        | "here ↓small↓ goes"           | "<p class='owl'>here␍  <small>small</small>␍  goes</p>" |
        | "here ↑sup↑ goes"             | "<p class='owl'>here␍  <sup>sup</sup>␍  goes</p>" |
        | "here abbr†desc ription† goes" | "<p class='owl'>here␍  <abbr title='desc ription'>abbr</abbr>␍  goes</p>" |
        | "here ✁del✁ goes"             | "<p class='owl'>here␍  <del>del</del>␍  goes</p>" |
        | "here ✿_span_nobrnobr✿_span_nobr goes" | "<p class='owl'>here␍  <nobr>nobr</nobr>␍  goes</p>" |
        | "here ÷deleted÷ goes"          | "<p class='owl'>here␍  <del>deleted</del>␍  goes</p>" |
        | "here λcodeλ goes"             | "<p class='owl'>here␍  <code>code</code>␍  goes</p>" |
        | "here ≡λbold codeλ≡ goes"     | "<p class='owl'>here␍  <strong><code>bold code</code></strong>␍  goes</p>" |
        | "here λ≡code bold≡λ goes"     | "<p class='owl'>here␍  <code><strong>code bold</strong></code>␍  goes</p>" |
        | "Hello, ≈World≈!"              | "<p class='owl'>Hello,␍  <em>World</em>!</p>" |

  Scenario Outline: Syntactic sugar
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                               | output                             |
        | "‒ Wikipedia, http://wikipedia.org" | "<p class='owl'><br/>␍  <small><a href='http://wikipedia.org'>Wikipedia</a></small></p>" |
        | "Wikipedia¹http://wikipedia.org"    | "<p class='owl'><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia†Best knowledge base†"    | "<p class='owl'><abbr title='Best knowledge base'>Wikipedia</abbr></p>" |
        | "Inplace picture¹http://mudasobwa.ru/images/am.jpg goes here." | "<p class='owl'><img alt='Inplace picture' src='http://mudasobwa.ru/images/am.jpg'/>␍  goes here.</p>" |
        | "http://mudasobwa.ru/images/am.jpg Standalone picture" | "<p class='owl'><figure>␍    <img src='http://mudasobwa.ru/images/am.jpg'/>␍    <figcaption>␍      <p>␍        Standalone picture␍      </p>␍    </figcaption>␍  </figure></p>" |

  Scenario Outline: Syntactic sugar with carriage returns
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should start with <output>

    Examples:
        | input                  | output                             |
        | "http://www.youtube.com/watch?v=gokeLEC8dZc" | "<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "http://youtu.be/gokeLEC8dZc" | "<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "YouTube http://youtu.be/gokeLEC8dZc inline test." | "<p class='owl'>YouTube http://youtu.be/gokeLEC8dZc inline test.</p>" |

  Scenario: Address
    Given the input string is "℁  ≡Twitter≡ ⏎  ☎ +1(987)5554321 ⏎  ✉ info@twitter.com"
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to
    """
    <address><strong>Twitter</strong>
      <br/>
      <span class='phone'>☎ +1(987)5554321</span>
      <br/>
      <span class='email'>✉ info@twitter.com</span></address>
    """
  
  Scenario Outline: Magnets
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                  | output                             |
        | "☎ +1(987)5554321"    | "<p class='owl'><span class='phone'>☎ +1(987)5554321</span></p>" |
        | "✉ info_twitter.com"   | "<p class='owl'><span class='email'>✉ info_twitter.com</span></p>" |
        | "✎ mudasobwa"          | "<p class='owl'><span style='white-space: nowrap;'><a href='http://mudasobwa.livejournal.com/profile?mode=full'><img src='http://l-stat.livejournal.com/img/userinfo.gif' alt='[info]' style='border: 0pt none ; vertical-align: bottom; padding-right: 1px;' height='17' width='17'></a><a href='http://mudasobwa.livejournal.com/?style=mine'><b>mudasobwa</b></a></span></p>" |
        | "☇ id001"               | "<p class='owl'><a name='id001'>​</a></p>" |
        
  Scenario Outline: Flushes
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input     | output                             |
        | "A ⏎ B"   | "<p class='owl'>A␍  <br/>␍  B</p>"  |
        | "A —— B"  | "<p class='owl'>A</p>␍<hr/>␍<p class='owl'>B</p>" |

  Scenario Outline: Linewides
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "List: • li1 • li2" | "<p class='owl'>List:</p>␍<ul class='fancy'>␍  <li>li1␍  </li>␍  <li>li2</li>␍</ul>" |
        | "Data: ▶ dt — dd ▶ dt — dd" | "<p class='owl'>Data:</p>␍<dl>␍  <dt>dt</dt>␍  <dd>dd␍  </dd>␍  <dt>dt</dt>␍  <dd>dd</dd>␍</dl>" |
        | "§1 Header" | "<h1>Header</h1>" |

  Scenario Outline: Handshakes
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                 | output                             |
        | "Let we have A ⊂ ∅." | "<p class='owl'>Let we have␍  <mathml>A ⊂ ∅</mathml>.</p>" |

  Scenario Outline: Markdown atavisms ⇒ links
    Given the input string is <input>
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "Here ![Image](http://mudasobwa.ru/images/am.jpg) goes" | "<p class='owl'>Here␍  <img alt='Image' src='http://mudasobwa.ru/images/am.jpg'/>␍  goes</p>" |
        | "![Figure](http://mudasobwa.ru/images/am.jpg)" | "<p class='owl'><figure>␍    <img src='http://mudasobwa.ru/images/am.jpg'/>␍    <figcaption>␍      <p>␍        Figure␍      </p>␍    </figcaption>␍  </figure></p>" |
        | "Here [Link](http://wikipedia.org/) goes" | "<p class='owl'>Here␍  <a href='http://wikipedia.org/'>Link</a>␍  goes</p>" |
        | "Here _italic_ goes" | "<p class='owl'>Here␍  <em>italic</em>␍  goes</p>" |
        | "Here **bold** goes" | "<p class='owl'>Here␍  <strong>bold</strong>␍  goes</p>" |
        | "Here `code` goes" | "<p class='owl'>Here␍  <code>code</code>␍  goes</p>" |

  Scenario: Adding spice
    Given the input string is "List: × li1 × li2"
    And parser is "html"
    And rule "×" is added to mapping as "li" in "linewide" section with "ol" enclosure
    When input string is processed with parser
    Then the result should equal to 
      """
      <p class='owl'>List:</p>
      <ol>
        <li>li1
        </li>
        <li>li2</li>
      </ol>
      """

  Scenario: Removing spice
    Given the input string is "List: ◦ li1 ◦ li2"
    And parser is "html"
    And rule "◦" is removed from mapping
    When input string is processed with parser
    Then the result should equal to "<p class='owl'>List: ◦ li1 ◦ li2</p>"

  Scenario: Standalone images
    Given the input string is
      """
      ---
      Preamble: given
      ---
      
      〉 http://mudasobwa.ru/i/self.jpg With caption
        ‒ Wiki, http://wikipedia.ru
      
      Nice?
      """
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to
    """
    <blockquote>
      <div class='blockquote'>http://mudasobwa.ru/i/self.jpg With caption
        <br/>
        <small><a href='http://wikipedia.ru'>Wiki</a></small>
      </div>
    </blockquote>
    <p class='owl'>Nice?</p>
    """

  Scenario: Blockquotes
    Given the input string is
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
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to
    """
    <h2>Blockquotes</h2>
    <blockquote>
      <div class='blockquote'>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere
    erat a ante.
      </div>
      <blockquote>
        <blockquote>
          <blockquote>
            <div class='blockquote'>Nested blockquote first line
            </div>
          </blockquote>
        </blockquote>
        <div class='blockquote'>Nested blockquote second line
        </div>
      </blockquote>
      <div class='blockquote'>Lorem ipsum para text 2.</div>
    </blockquote>
    <p class='owl'>Some para text.</p>
    <blockquote>
      <div class='blockquote'>Intro 1.
      </div>
      <ul class='fancy'>
        <li>list item
          <strong>with bold</strong>
          1
        </li>
        <li>list item
          <em>emphasized</em>
        </li>
        <ul class='fancy'>
          <li>nested list item 1
          </li>
          <li>nested list item 2</li>
        </ul>
      </ul>
    </blockquote>
    <blockquote>
      <div class='blockquote'>Blockquote standalone.</div>
    </blockquote>
    <blockquote>
      <div class='blockquote'>Intro 2.
      </div>
      <ul class='fancy'>
        <li>list item 2.1
        </li>
        <li>list item 2.2
        </li>
      </ul>
      <div class='blockquote'>Continuing intro 2.</div>
    </blockquote>
    <p class='owl'>Blockquote standalone.</p>
    """

