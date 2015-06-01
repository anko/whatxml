# whatxml

XML/HTML templating with [LiveScript][1]'s [cascade][2] syntax.

"What XML?"  *None, ever again.*

[![npm package](https://img.shields.io/npm/v/whatxml.svg?style=flat-square)][3]
[![Build status](https://img.shields.io/travis/anko/whatxml.svg?style=flat-square)][4]
[![npm dependencies](https://img.shields.io/david/anko/whatxml.svg?style=flat-square)][5]

<!-- !test program
# Prepend module import statement to input
# Remove trailing newline from output
sed '1s/^/whatxml = require ".\\/index.ls" ;/' \
| lsc \-\-stdin \
| head -c -1
-->

<!-- !test in initial example -->

```ls
x = whatxml \html
  .. \head
    .. \title ._ "My page"
    ..self-closing \link rel : \stylesheet type : \text/css href : \main.css
  .. \body
    .. \p ._ (.content)

console.log x.to-string { content : "Here's a paragraph." }
```

→

<!-- !test out initial example -->

```html
<html><head><title>My page</title><link rel="stylesheet" type="text/css" href="main.css" /></head><body><p>Here&#x27;s a paragraph.</p></body></html>
```

## API summary

-   `.. <string> [<attr-object>]` adds a tag (with optional attributes)
-   `..self-closing <string> [<attr-object>]` same, but a self-closing tag
-   `.. <object>` sets attributes
-   `.._ <string>` adds text
-   `..raw <string>` adds text (without escaping it)
-   `..comment <string>` adds a comment

`to-string` recursively renders that tag's tree.

Any of the setters can also take a function parameter which is called with the
value passed to `to-string`.  It is expected to return the value that should be
inserted at that point.  (See [§ *Templating*][6].)

## API tutorial

### Basics

Create a **root tag**, call it with a `string` to create **child tags**, with
an `object` to **add attributes** or call `_` to **add text** between the tags.

<!-- !test in basics example -->

```ls
gandalf = whatxml \person      # Create a root tag.
  .. { profession : \wizard }  # Set an attribute.
  .. \name                     # Add a child node.
    .._ "Gandalf"              # Put text in it.
console.log gandalf.to-string!
```

<!-- !test out basics example -->

```xml
<person profession="wizard"><name>Gandalf</name></person>
```

Handy shortcut:  When creating a tag, pass attributes as an object.

<!-- !test in attribute shortcut example -->

```ls
t = whatxml \tower lean : "3.99"
  .. \place city : "Pisa", country : "Italy"
console.log t.to-string!
```

<!-- !test out attribute shortcut example -->

```xml
<tower lean="3.99"><place city="Pisa" country="Italy"></place></tower>
```

Add **self-closing tags** and **comments**.

<!-- !test in self-closing tag and comment example -->

```ls
x = whatxml \a
  ..self-closing \b
  ..comment "what"
console.log x.to-string!
```

<!-- !test out self-closing tag and comment example -->

```xml
<a><b /><!--what--></a>
```

You can have **stand-alone attributes** without a value by setting them to
`true`.  ([It's invalid XML][7], but fine in HTML.)

<!-- !test in stand-alone attribute example -->

```ls
whatxml \input { +selected }
  ..to-string! |> console.log
```

<!-- !test out stand-alone attribute example -->

```ls
<input selected></input>
```

Setting an attribute to another value overwrites the previous value.  Setting
attributes to `false`, `null` or `undefined` removes that attribute, if
present.

Text is **escaped automatically**, but you can **bypass** that with `raw` if
you have ready-escaped text (e.g. from [`marked`][8]).

<!-- !test in escaping example -->

```ls
greeting = whatxml \p
  .._ "What's up <3"
console.log greeting.to-string!

x = whatxml \p
  ..raw "<em>I know this is &gt; properly escaped already</em>"
console.log x.to-string!
```

<!-- !test out escaping example -->

```xml
<p>What&#x27;s up &#x3C;3</p>
<p><em>I know this is &gt; properly escaped already</em></p>
```

You can also have **multiple top-level tags**:

<!-- !test in multiple top-level example -->

```ls
x = whatxml!
  .. \a
  .. \b
console.log x.to-string!
```

<!-- !test out multiple top-level example -->

```xml
<a></a><b></b>
```

### Templating

To **generate content based on data**, you can pass a function to any setter
call.  When a tag's `to-string` is called, the functions passed to its setters
before are called with its arguments to produce the final value.

<!-- !test in templating example -->

```ls
link = whatxml \a href : (.href)
  .._ (.name.to-upper-case!)

console.log link.to-string name : \google    href : "https://google.com"
console.log link.to-string name : \runescape href : "http://runescape.com"
```

<!-- !test out templating example -->

```xml
<a href="https://google.com">GOOGLE</a>
<a href="http://runescape.com">RUNESCAPE</a>
```

## Limitations

Check your XML comments are [valid by the XML spec][9]:  They may not contain
two consecutive hyphens (`--`).  Whatxml doesn't check for you.

[`CDATA`-sections][10] and XML declarations (`<?xml version="1.0"?>` and such)
aren't explicitly supported, but you can happily add them using `raw`.

## Related libraries

Whatxml aims to be a serious general-purpose XML/HTML templating engine for
[LiveScript][11]'s syntax.

Existing attempts have their flaws:

-   [`live-templ`][12] came closest to my goals, but objects in nested arrays
    cannot represent comments, raw text data or self-closing tags. It also has
    no templating.
-   [`create-xml-ls`][13] is based on nested objects, so it can't represent two
    tags with the same name on the same level of nesting…
-   [`htmls`][14] supports only the base HTML tag set.  Templating code is
    [stringly typed][15] and compiled separately.

[1]: http://livescript.net/
[2]: http://livescript.net/#property-access-cascades
[3]: https://www.npmjs.com/package/whatxml
[4]: https://travis-ci.org/anko/whatxml
[5]: https://david-dm.org/anko/whatxml
[6]: #templating
[7]: http://stackoverflow.com/questions/6926442/is-an-xml-attribute-without-value-valid
[8]: https://github.com/chjj/marked
[9]: http://www.w3.org/TR/2006/REC-xml11-20060816/#sec-comments
[10]: http://en.wikipedia.org/wiki/CDATA
[11]: http://livescript.net/
[12]: https://www.npmjs.org/package/live-tmpl
[13]: https://www.npmjs.org/package/create-xml-ls
[14]: https://www.npmjs.org/package/htmls
[15]: http://c2.com/cgi/wiki?StringlyTyped
