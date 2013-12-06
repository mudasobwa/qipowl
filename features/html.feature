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
        | "here ÷deleted÷ goes"    | "<p class='dropcap'>here <del>deleted</del> goes</p>" |
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
        | "‒ Wikipedia, http://wikipedia.org" | "<p class='dropcap'><br/><small><a href='http://wikipedia.org'>Wikipedia</a></small></p>" |
        | "Wikipedia¹http://wikipedia.org" | "<p class='dropcap'><a href='http://wikipedia.org'>Wikipedia</a></p>" |
        | "Wikipedia†Best knowledge base†" | "<p class='dropcap'><abbr title='Best knowledge base'>Wikipedia</abbr></p>" |
        | "Inplace picture¹http://mudasobwa.ru/images/am.jpg goes here." | "<p class='dropcap'><img alt='Inplace picture' src='http://mudasobwa.ru/images/am.jpg'/> goes here.</p>" |
        | "http://mudasobwa.ru/images/am.jpg Standalone picture" | "<pclass='dropcap'><figure><imgsrc='http://mudasobwa.ru/images/am.jpg'/><figcaption><p>Standalonepicture</p></figcaption></figure></p>" |

  Scenario Outline: Syntactic sugar with carriage returns
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should start with to <output>

    Examples:
        | input                  | output                             |
        | "http://www.youtube.com/watch?v=gokeLEC8dZc" | "<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "http://youtu.be/gokeLEC8dZc" | "<iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |
        | "YouTube http://youtu.be/gokeLEC8dZc inline test." | "<p class='dropcap'>YouTube</p><iframe class='youtube' width='560' height='315' src='http://www.youtube.com/embed/gokeLEC8dZc'" |

  Scenario: Address
    Given the input string is "℁  ≡Twitter≡ ⏎  ☎ +1(987)5554321 ⏎  ✉ info@twitter.com"
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to "<address><strong>Twitter</strong> <br/> <span class='phone'>☎ +1(987)5554321</span> <br/> <span class='email'>✉ info@twitter.com</span></address>"
  
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
        | "A ⏎ B"   | "<p class='dropcap'>A <br/> B</p>"  |

  Scenario Outline: Flushes (multiliners)
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should be multiline and almost equal to <output>

    Examples:
        | input     | output                             |
        | "A —— B"  | "<p class='dropcap'>A</p><hr/><p class='dropcap'>B</p>" |

  Scenario Outline: Linewides
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should be multiline and almost equal to <output>

    Examples:
        | input               | output                             |
        | "List: • li1 • li2" | "<p class='dropcap'>List:</p><ul><li>li1</li><li>li2</li></ul>" |
        | "Data: ▶ dt — dd ▶ dt — dd" | "<p class='dropcap'>Data:</p><dl><dt>dt</dt><dd>dd</dd><dt>dt</dt><dd>dd</dd></dl>" |
        | "§1 Header" | "<h1>Header</h1>" |

  Scenario Outline: Handshakes
    Given the input string is <input>
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input                 | output                             |
        | "Let we have A ⊂ ∅." | "<p class='dropcap'>Let we have <mathml>A ⊂ ∅</mathml> .</p>" |

  Scenario Outline: Markdown atavisms ⇒ links
    Given the input string is <input>
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to <output>

    Examples:
        | input               | output                             |
        | "Here ![Image](http://mudasobwa.ru/images/am.jpg) goes" | "<p class='dropcap'>Here <img alt='Image' src='http://mudasobwa.ru/images/am.jpg'/> goes</p>" |
        | "![Figure](http://mudasobwa.ru/images/am.jpg)" | "<pclass='dropcap'><figure><imgsrc='http://mudasobwa.ru/images/am.jpg'/><figcaption><p>Figure</p></figcaption></figure></p>" |
        | "Here [Link](http://wikipedia.org/) goes" | "<p class='dropcap'>Here <a href='http://wikipedia.org/'>Link</a> goes</p>" |
        | "Here _italic_ goes" | "<p class='dropcap'>Here <em>italic</em> goes</p>" |
        | "Here **bold** goes" | "<p class='dropcap'>Here <strong>bold</strong> goes</p>" |
        | "Here `code` goes" | "<p class='dropcap'>Here <code>code</code> goes</p>" |

  Scenario: Full processing
    Given the input string is taken from file "spec/full_input.tgm"
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    And the result is printed out to file "spec/full_output.html"
    Then the result should equal to content of file "spec/output.html"

  Scenario: Adding spice
    Given the input string is "List: × li1 × li2"
    And parser is "html"
    And rule "×" is added to mapping as "li" in "linewide" section with "ol" enclosure
    When input string is processed with parser
    Then the result should equal to 
      """
      <p class='dropcap'>List:</p>
      <ol><li>li1</li>
      <li>li2</li></ol>
      """

  Scenario: Removing spice
    Given the input string is "List: ◦ li1 ◦ li2"
    And parser is "html"
    And rule "◦" is removed from mapping
    When input string is processed with parser
    Then the result should equal to "<p class='dropcap'>List: ◦ li1 ◦ li2</p>"

  Scenario: Standalone images
    Given the input string is
      """
      ---
      Preamble: given
      ---
      
      〉
      http://mudasobwa.ru/i/self.jpg With caption
        ‒ Wiki, http://wikipedia.ru
      
      Nice?
      """
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to "<blockquote><divclass='blockquote'><figure><imgsrc='http://mudasobwa.ru/i/self.jpg'/><figcaption><p>Withcaption<br/><small><ahref='http://wikipedia.ru'>Wiki</a></small></p></figcaption></figure></div></blockquote><pclass='dropcap'>Nice?</p>"

  Scenario: Weird StackLevelTooDeep
    Given the input string is
      """
---
Preamble: given
---
      
  Да, я устал. Немного есть. ⏎
 Да, лихорадит и бросает. ⏎
   А в горле комом бьется спесь. ⏎
 От ресторанов до красавиц. ⏎
Боюсь работы, дней, себя

А ты ведь просто ⏎
      ищешь себя — ⏎
Тебе они — невзначай. ⏎
Знаешь ведь — проще прожить любя, ⏎
    даже, если — печаль．
      """
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to "<pclass='dropcap'>  Да,яустал.Немногоесть.<br/> Да,лихорадитибросает.<br/>   Авгорлекомомбьетсяспесь.<br/> Отресторановдокрасавиц.<br/>Боюсьработы,дней,себя</p>"

  Scenario: Weird Quote
    Given the input string is
      """
Λ
@@ -348,7 +348,7 @@ case "$DISTRO" in- rm -rf /usr /lib/nvidia-current/xorg/xorg+ rm -rf /usr/lib/nvidia-current/xorg/xorg
Λ

‒ https://github.com/MrMEEE/bumblebee/commit/a047be85247755cdbe0acce6#diff-1, https://github.com/MrMEEE/bumblebee/commit/a047be85247755cdbe0acce6#diff-1
"""
    And parser is "html"
    When input string is processed with parser
    Then the result should equal to
      """
<preclass='auto'>@@-348,7+348,7@@case"$DISTRO"in-rm-rf/usr/lib/nvidia-current/xorg/xorg+rm-rf/usr/lib/nvidia-current/xorg/xorg</pre><pclass='dropcap'><br/><small><ahref='https://github.com/MrMEEE/bumblebee/commit/a047be85247755cdbe0acce6#diff-1'>https://github.com/MrMEEE/bumblebee/commit/a047be85247755cdbe0acce6#diff-1</a></small></p>
      """

  Scenario: Weird behaviour with words starting with “ni”
    Given the input string is "Very define and defined and even defined? words"
    And parser is "html"
    And rules from "lib/tagmaps/markdown2html.yaml" are merged in
    When input string is processed with parser
    Then the result should equal to "<p class='dropcap'>Very define and defined and even defined? words</p>"

  Scenario: Blockquotes
    Given the input string is taken from file "data/blockquote.tg"
    And parser is "html"
    When input string is processed with parser
#    Then the result should be printed to stdout as is
    Then the result should equal to "<h2>Blockquotes</h2><blockquote><divclass='blockquote'>Loremipsumdolorsitamet,consecteturadipiscingelit.Integerposuereerataante.</div><blockquote><blockquote><blockquote><divclass='blockquote'>Nestedblockquotefirstline</div></blockquote></blockquote><divclass='blockquote'>Nestedblockquotesecondline</div></blockquote><divclass='blockquote'>Loremipsumparatext2.</div></blockquote><pclass='dropcap'>Someparatext.</p><blockquote><divclass='blockquote'>Intro1.</div><ul><li>listitem<strong>withbold</strong>1</li><li>listitem<em>emphasized</em></li><ul><li>nestedlistitem1</li><li>nestedlistitem2</li></ul></ul></blockquote><blockquote><divclass='blockquote'>Blockquotestandalone.</div></blockquote><blockquote><divclass='blockquote'>Intro2.</div><ul><li>listitem2.1</li><li>listitem2.2</li></ul><divclass='blockquote'>Continuingintro2.</div></blockquote><pclass='dropcap'>Blockquotestandalone.</p>"  
  
  Scenario: Blockquotes with class method
    Given the input string is taken from file "data/blockquote.tg"
    And parser class is "html"
    When input string is processed with parser’s class function
    Then the result should equal to "<h2>Blockquotes</h2><blockquote><divclass='blockquote'>Loremipsumdolorsitamet,consecteturadipiscingelit.Integerposuereerataante.</div><blockquote><blockquote><blockquote><divclass='blockquote'>Nestedblockquotefirstline</div></blockquote></blockquote><divclass='blockquote'>Nestedblockquotesecondline</div></blockquote><divclass='blockquote'>Loremipsumparatext2.</div></blockquote><pclass='dropcap'>Someparatext.</p><blockquote><divclass='blockquote'>Intro1.</div><ul><li>listitem<strong>withbold</strong>1</li><li>listitem<em>emphasized</em></li><ul><li>nestedlistitem1</li><li>nestedlistitem2</li></ul></ul></blockquote><blockquote><divclass='blockquote'>Blockquotestandalone.</div></blockquote><blockquote><divclass='blockquote'>Intro2.</div><ul><li>listitem2.1</li><li>listitem2.2</li></ul><divclass='blockquote'>Continuingintro2.</div></blockquote><pclass='dropcap'>Blockquotestandalone.</p>"  
  
#  Scenario: HTML ⇒ TG
#    Given the input string is taken from file "spec/output.html"
#    And parser is "html"
#    When input string is reversed with unparse_and_roll
#    Then the result should equal to content of file "spec/input.tgm"

