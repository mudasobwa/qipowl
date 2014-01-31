Principles
==========

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

Applications
============

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

Why?
====

Just because it’s 2013 all around. Unicode came already and those fancy 
symbols are easily mapped to the keyboard layouts. The brackets, used
in old good Markdown are ugly, look at how they might be introduced:

    I like Markdown¹http://daringfireball.net/projects/markdown/syntax

Markdown lacks a lot of modern features (properties of text).

Markdown does not provide a blanket set of marks, fully covering 
claims to markup language.

Parsing
=======

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

