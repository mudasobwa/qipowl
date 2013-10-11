![Typogrowl](/images/owl.png)

_Typogrowl_ is the next generation markup environment. It’s not the
markup language only, since it provides the very efficient and straightforward
library to produce custom markups. It′s not the markup library either,
since it comes with ready-to-use markdown-like markup and 2HTML converter.

The main idea of _Typogrowl_ is to yield the power of 
[DSL in Ruby](http://jroller.com/rolsen/entry/building_a_dsl_in_ruby).
The whole input text is treated neither more nor less than `DSL`. 
That gives the user an ability to make virtually every term in input text
the _operating entity_.

_Typogrowl_ utilizes UTF-8 heavily. The standard markup (here and further:
**Typogrowl markup**, or **TGM**) lays on unicode characters instead of
legacy asterisks and underscores in markdown. It brings the better 
readability to plain text before it’s processed with _Typogrowl_ and
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

The valuable subset of HTML5 is implemented directly, plus the user may
eventually extend the list of understandable tags.

The markup-specific symbols, like “▶” and “•” in the previous example
may be mapped to keyboard (see `typo` file within `data` directory of the 
project.

## Internals

_Typogrowl_ markup implementation consists of two parts: markup definition
(kinda `yaml` file) and markup processor. The latter derives from base
processor implementation `Typogrowl::Bowler`.

### Markup definition

_Typogrowl_ understands six types of ‘operators’:

* flush
* block
* magnet
* inplace
* linewide
* custom

#### :flush

The operators in this group are executed immediately and do not break
the control flow. Technically, they are simply being substituted with 
their representation.

    :flush
      :⏎ : :br

means that “⏎” anywhere in text will be substituted with “<br>”

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
closing element.

    :inplace
      :≡ : :strong

will convert

    That is ≡bold≡ text.

into

    That is <strong>bold</strong> text.

#### :linewide

Those are not require closings, since they are operated on the _rest_ of
the text. Support nesting by prepending tags with non-breakable space:

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

#### :custom

Custom is not yet fully powerful mechanism to make substitutions inplace
for generic words. Please use on your own risk.



## Installation

Add this line to your application's Gemfile:

    gem 'typogrowl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typogrowl

## Usage

    require 'typogrowl'
    
    …

    tg =  Typogrowl::Html.new 
    tg.in = "#{text}"

    puts tg.out

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
