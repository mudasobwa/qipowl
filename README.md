![qipowl](/images/owl.png)

## Name

_qipowl_ (pronounced as **keep all**)

[![Build Status](https://travis-ci.org/mudasobwa/qipowl.png)](https://travis-ci.org/mudasobwa/qipowl)
[![Gemnasium](https://gemnasium.com/mudasobwa/qipowl.png?travis)](https://gemnasium.com/mudasobwa/qipowl)

---

[Introduction into techniques](http://rocket-science.ru/qipowl/)

## Intro

_qipowl_ is the next generation parser environment. It’s not the
library for parsing, rather it is the framework to build extensive
parsers for virtually every markup anyone may imagine.

The main idea of _qipowl_ is to yield the power of 
[DSL in Ruby](http://jroller.com/rolsen/entry/building_a_dsl_in_ruby).
The whole input text is treated neither more nor less than `DSL`. 
That gives the user an ability to make virtually every term in input text
the _operating entity_.

## Examples

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
* inplace
* linewide
* handshake
* kiss
* custom

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

#### :inplace

Acts mostly like `:block` but inside one text block (text blocks are
likely paragraphs, delimited with double carriage returns.) Requires
closing element. Inplace operators are of highest priority and may
overlap.

    :inplace
      :≡ : :strong

will convert

    That is ≡bold≡ text.

into

    That is <strong>bold</strong> text.

#### :linewide

Those are not require closings, since they are operated on the _rest_ of
the text. Support nesting by prepending tags with _non-breakable space_:

    :linewide
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

#### :handshake

**TODO** rewrite examples for latex

The group contains operators, acting on left and right operands between
the delimiters given. By default it takes the whole line from `^` till `$`.

    :handshake :
      :∈ : :mathml
      :⊂ :
        :tag  : :mathml
        :from : '\s'
        :till : '.'
        
The following syntax 

    Let we have A ⊂ ∅. Then the following formula is OK:
    ∀ a ∈ ∅
    which is evident, though.
    
will produce:

    Let we have <mathml>A ⊂ ∅</mathml>. Then the following formula is OK:
    <mathml>∀ a ∈ ∅</mathml>
    which is evident, though.

#### :kiss

Almost the same as `:handshake` but operates on the preceeding/following pair of
text piece without spaces. E.g.

    :kiss
      :÷ : :mathml

The following syntax 

    The formula 12 ÷ 5 is simple.
    
will produce:

    The formula <mathml>12 ÷ 5</mathml> is simple.

#### :custom

Custom is not yet fully powerful mechanism to make substitutions inplace
for generic words. Please use on your own risk.

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

    gem 'typogrowl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typogrowl

## Usage

```ruby
require 'typogrowl'
…
tg =  Qipowl::Html.new 
puts tg.parse_and_roll(text)
```

or even simplier

```ruby
require 'typogrowl'
…
tg =  Qipowl.tg_md__html # typogrowl markup _and_ markdown

puts tg.parse_and_roll(text)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
