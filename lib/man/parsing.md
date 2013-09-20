Principles
==========

**Typegrowl** is kinda 
[Markdown](http://daringfireball.net/projects/markdown/syntax) successor,
or, if you like, a Markdown². **Typegrowl** uses extended unicode symbols
to specify more clean and readable source files and (boom!) ruby DSL to
interpret them. E.g. the data definitions look like:

    ▶ Data term — definition goes here

Headings:

    §§ This is a second-level heading

Bold and emphasis:

    The following ≡text≡ goes strong and this one is ≈emphasized≈.

Comments are possible as well:

    ✎ FIXME! Not to forget add this to parsing!

etc.

The other goal is to generate more typographically correct output, with
proper quotation marks (“” instead of "" etc.)

Why?
====

Just because it’s 2013 all around. Unicode came already and those fancy 
symbols are easily mapped to the keyboard layouts. The brackets, used
in old good Markdown are ugly, look at how they might be introduced:

    I like Markdown¹http://daringfireball.net/projects/markdown/syntax

Markdown lacks a lot of modern features (properties of text,) such as:
- tags
- ???

Markdown does not provide a blanket set of marks, fully covering 
claims to markup language.


Parsing
=======

Parsing is the most sexy part of **Typegrowl** bowels, since it’s done
almost without any external parsing; `.tg` files are the ruby scripts
themselves. WTF? Let me explain.

Let we have a `.tg` file of the following structure:

    § Typegrowl

    ✎ include language reference here
    ≡Typegrowl≡ is the most exciting ruby DSL application example. As it
    is stated in markdown reference:

    » Readability, however, is emphasized above all else. 
    » A Markdown-formatted document should be publishable as-is, 
    » as plain text, without looking like it’s been marked up with 
    » tags or formatting instructions.
    » — http://daringfireball.net/projects/markdown/syntax

Now we simply give the source to ruby interpreter, which knowns, that
`§` is *in fact* ruby function, which transforms that to any other syntax
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

- find the link in the input, according to simple pattern like 
`(?:^|\P{L})(?<proto>[hftps/:]*)(?<path>\S+?)(?:\s|$)`
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

We will store all the links in some array and substitute them in input
with array index as shown below:

    Wiki¹⚓0 says, that Saint-Petersburg is the most beatuful city in the world:
    SPb in the night¹⚐1

### Links and abbrs: final normalization

Now there are no nasty “http://” links without prepending DSL. Nice.
Let’s go further: we don’t like links and abbrs in format 

- `title¹href`
- and `term†explanation`

    