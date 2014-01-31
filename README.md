![qipowl](/images/owl.png)

## Name

_qipowl_ (pronounced as **keep all**)

[![Build Status](https://travis-ci.org/mudasobwa/qipowl.png)](https://travis-ci.org/mudasobwa/qipowl)
[![Gemnasium](https://gemnasium.com/mudasobwa/qipowl.png?travis)](https://gemnasium.com/mudasobwa/qipowl)
[![Stories in Ready](https://badge.waffle.io/mudasobwa/qipowl.png?label=ready)](http://waffle.io/mudasobwa/qipowl)

**Status:** Minimum viable product

---

[Introduction into techniques](http://rocket-science.ru/qipowl/)

## Intro

The main idea of _qipowl_ is to yield the power of 
[DSL in Ruby](http://jroller.com/rolsen/entry/building_a_dsl_in_ruby).
The whole input text is treated neither more nor less than `DSL`. 
That gives the user an ability to make virtually every term in input text
the _operating entity_.

## Principles

**Qipowl** is a Ruby parsing library. The parsing is done via
DSL exactly as [Ouroboros](http://en.wikipedia.org/wiki/Ouroboros)
eats it’s own tail. 

The whole input is treated as Ruby source code and executed respectively.
To prevent collisions of input with built-in ruby methods, the ASCII symbols
in the input are being translated into their
[fullwidth equivalents](http://en.wikipedia.org/wiki/Halfwidth_and_fullwidth_forms#Chart)
before execution (and back to ASCII after the parsing is done.)

Let’s say we have a string “Hello world” as input. It became ‘encoded’ into:
“Ｈｅｌｌｏ ｗｏｒｌｄ”, executed as Ruby code (exactly as e. g. `puts rand`
would) and finally ‘decoded’ back to ASCII. Whether the parser knows anything
about ‘Ｈｅｌｌｏ’ or ‘ｗｏｒｌｄ’ it would be executed. Say, we have

    def ｗｏｒｌｄ *args
      "ｂｒａｖｅ ｎｅｗ #{__callee__}"
    end

thus the output will be:

    # ⇒ Hello brave new world

More about may be found at [project page](http://rocket-science.ru/qipowl/).

## Applications

**Qipowl** has a wide list of applications. The “markright”, descendant
of “markup” and “markdown” is presented [here](http://qipowl.herokuapp.com).

**Qipowl HTML** uses extended unicode symbols
to specify more clean and readable source files and (boom!) ruby DSL to
interpret them. E.g. the data definitions look like:

    ▶ Data term — definition goes here

Headings:

    §1 This is a second-level heading

Bold and emphasis:

    The following ≡text≡ goes strong and this one is ≈emphasized≈.

Comments are possible as well:

    ✍ FIXME! 
    Not to forget add this to parsing!
    ✍

etc.

## Why?

Just because it’s 2013 all around. Unicode came already and those fancy 
symbols are easily mapped to the keyboard layouts. The brackets, used
in old good Markdown are ugly, look at how they might be introduced:

    I like Markdown¹http://daringfireball.net/projects/markdown/syntax

Markdown lacks a lot of modern features (properties of text).

Markdown does not provide a blanket set of marks, fully covering 
claims to markup language.

## Parsing

Parsing is the most sexy part of **Qipowl** bowels, since it’s done
almost without any external parsing; input files are the ruby scripts
themselves. WTF? Let me explain.

Let we have an input file of the following structure:

    §1 Qipowl

    ✍ FIXME 
    include language reference here
    ✍

    ≡Qipowl≡ is the most exciting ruby DSL application example. As it
    is stated in markdown reference:

    〉 Readability, however, is emphasized above all else. 
    A Markdown-formatted document should be publishable as-is, 
    as plain text, without looking like it’s been marked up with 
    tags or formatting instructions.
    — http://daringfireball.net/projects/markdown/syntax

Now we simply give the source to ruby interpreter, which knowns, that
`§1` is *in fact* ruby function, which transforms that to any other syntax
we want. To HTML, for instance.

## Parsing problems

Not all the constructions may be passed to ruby script as is. There are
four exceptions:

- **blockquotes**, which are in fact kinda documents inside documents, because
they might be nested and they may include any other markup;
- **images**, **videos**, etc. which may be typed as the hyperlink only;
- **anchors, abbrs etc.**, the elements which are not “symbol-text” formed.
They rather are looking like “text-symbol-text” and unfortunately should
be preparsed to supply correct ruby DSL;
- **lists and data definitions**, are to be surrounded with `<ul>`/`<dd>` tags;
- **tables**… Bah, I didn’t think most about tables yet. They are ugly.

### Links

Links might be:
- **anchors** 
  - Wiki says¹http://wikipedia.org
  - Wiki clone¹/wiki
  - — Wikipedia, http://wikipedia.org   
the latter may be found in quotations only.
- **images**
  - http://localhost/a.png
  - Best views of Hornsjø¹http://localhost/a.png
- **videos**
  - http://youtu.be/SAJ_TzLqy1U
  - http://www.youtube.com/watch?v=SAJ_TzLqy1U

Abbrs are looking (and processing) mostly like links, but now we may
forget about them:
- **abbrs**
  - Wiki†Best online knowledge base ever†


Links are being parsed in the following manner:

- find the link in the input, according to simple pattern `URI.regexp`
- determine whether it is an image, video or link to page by downloading
and analyzing the headers
- TODO copying the image to the host computer, providing the watermark
with copyright and any other significant information
- TODO instead of previous two actions we might simply analyze it by extension
e.g. if there is no internet connection available
- prepending the link with special character (understood by DSL)

After all is done, we yield smth like `⚐ http://localhost.a.png` in place of
`http://localhost.a.png` and `⚓ http://localhost/index.html` in place of
`http://localhost/index.html`


### Examples

This chapter should be the last one, but who wants to read technical details
without any clue of how they might be applied? So, here we go.

### Shipping with: Markright

Right is looking right past up and down, right? _qipowl_ comes with built-in
markright parser, which is superset of markdown.

_qipowl_ markright utilizes UTF-8 heavily. The standard markup (here and further:
_qipowl markup_, or _qp_) lays on unicode characters instead of
legacy asterisks and underscores in markdown. It brings the better 
readability to plain text before it’s processed with _qipowl_ and
allows more readable `DSL` for processing. For instance, the input:

    §3 Emphasized text

    There are four standard modifiers for emphasizing text:
    ▶ “≡” — bold
    ▶ “≈” — italic
    ▶ “↓” — small
    ▶ “λ” — code

    The formers are to surround the target text piece.
    This text contains:
    • ≡bold≡,
    • ≈italics≈,
    • ↓small↓ 
    • and even some λcodeλ.

will be processed as:

```html
<h3>Emphasized text</h3>
<p class='dropcap'>There are four standard modifiers for emphasizing text:</p>
<dl><dt>“≡”</dt><dd>bold</dd>
<dt>“≈”</dt><dd>italic</dd>
<dt>“↓”</dt><dd>small</dd>
<dt>“λ”</dt><dd>code</dd></dl>
<p class='dropcap'>The formers are to surround the target text piece.
This text contains:</p>
<ul><li><strong>bold</strong>,</li>
<li><em>italics</em>,</li>
<li><small>small</small></li>
<li>and even some <code>code</code>.</li></ul>
```

The valuable subset of HTML5 is implemented directly, plus the user may
eventually extend the list of understandable tags.

The markup-specific symbols, like “▶” and “•” in the previous example
may be mapped to keyboard (see `typo` file within `data` directory of the 
project.

## Internals

_qipowl_ markup implementation consists of two parts: markup definition
(kinda `yaml` file) and markup processor. The latter derives from base
processor implementation `Qipowl::Bowler`.

### Markup definition

_qipowl_ understands six types of ‘operators’:

* flush
* block
* magnet
* grip
* regular
* self

#### :flush

The operators in this group are executed immediately and do not break
the control flow. Technically, they are simply being substituted with 
their representation.

    :flush
      :⏎ : :br

means that “⏎” anywhere in text will be substituted with “&lt;br&gt;”

#### :block

This group contains operators, which are driving the blocks. Such a block
should start with the operator and ends with it. Operator may receive an
additional parameter, located on the same string as the opening operator.

    :block
      :Λ : :pre

means that the following block:

    Λ ruby
      @mapping[:block].each { |tag, htmltag|
        break if tag < :inplace
      }
    Λ

is to be left intouch (except of html is escaped inside) 
and surrounded with `pre` tags:

    <pre class='ruby'>
      @mapping[:block].each { |tag, htmltag|
        break if tag &lt; :inplace
      }
    </pre>

This operator is the only one which preserves the line breaks.

#### :magnet

Almost the same as `:inplace` but does not require closing match.
Operates on the following text piece until the space. E.g.

    :magnet
      :☎ : :span†phone

will produce

    <span class='phone'>☎ +1(987)5554321</span>

for the markup:

    ☎ +1(987)5554321

#### :grip

Acts mostly like `:block` but inside one text block (text blocks are
likely paragraphs, delimited with double carriage returns.) Requires
closing element. Inplace operators are of highest priority and may
overlap.

    :grip
      :≡ : :strong

will convert

    That is ≡bold≡ text.

into

    That is <strong>bold</strong> text.

#### :regular

Those are not require closings, since they are operated on the _rest_ of
the text. Support nesting by prepending tags with _non-breakable space_:

    :regular
      :• : li

The following syntax 

    • Line item 1
     • Nested li 1
     • Nested li 2
    • Line item 2

will produce:

    <ul><li>Line item 1</li>
    <ul><li>Nested li 1</li>
    <li>Nested li 2</li></ul>
    <li>Line item 2</li></ul>

### Extending

Extending _qipowl_ is as easy as writing a couple of strings in YAML format.
Let’s take a look at additional rules file for markdown support:

```yaml
:synsugar :
  # Code blocks, 4+ spaces indent
  '(?x-mi:(\R)((?:(?:\R)+(?:\s{4,}|\t).*)+\R)(?=\R))' : "\\1\nΛ auto\\2Λ\n"
  # Pictures
  '!\[(.*?)\]\((.*?)\)' :  '⚓\2 \1⚓'
  # Links
  '\[(.*?)\]\((.*?)\)' :  '⚓\2 \1⚓'
  # Blockquotes
  '^\s*>' : '〉'
  '^\s*>\s*>' : '〉 〉'
  '^\s*\*\s*\*' : '〉 •'
  '^\s+\*' : '• •'


:inplace : 
  :'__' : :strong
  :'**' : :strong
  :'_' : :em
  :'*' : :em
  :'`' : :code
```

Bold, italic, code, images, links, blockquotes (including nesteds) are now 
supported by _qipowl_. Let any one of you who is not delighted with, 
be the first to throw a stone at me.

Need custom support for `github`-flavored markdown _strikethrough_? Oneliner
inside an `:inplace` section of custom rules came on scene:

```yaml
  :'~~' :strike
```

#### Sophisticated extending

Whether one needs more sophisticated rules, she is to write her own 
descendant of `Bowler` class, implementing DSL herself. E.g. `Html`
markup uses the following DSL for handling video links to YouTube:

```ruby
 # Handler for Youtube video
 # @param [Array] args the words, gained since last call to {#harvest}
 # @return [Nil] nil
 def ✇ *args
   id, *rest = args.flatten
   harvest nil, orphan(rest.join(SEPARATOR)) unless rest.vacant?
   harvest __callee__, "<iframe width='560' height='315' 
           src='http://www.youtube.com/embed/#{id}' 
           frameborder='0' allowfullscreen></iframe>"
 end
```

Here we harvest the previously gained words (`rest`) and transform copy-pasted
link to video into embedded frame with video content as by YouTube.

## Installation

Add this line to your application's Gemfile:

    gem 'qipowl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qipowl

## Usage

```ruby
require 'qipowl'
…
result =  Qipowl.parse text # qipowl markup _and_ markdown
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
