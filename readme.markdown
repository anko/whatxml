# whatxml

DRY `(X|HT|XHT)ML` templating with [LiveScript]'s [cascade] syntax.

## Usage

### Basics

Make a root tag.

```ls
p = whatxml \person
console.log p.to-string!
```
```xml
<person></person>
```

Add child tags, attributes and text.

```ls
gandalf = whatxml \person
  .. { profession : \wizard }  # Set an attribute.
  .. \name                     # Add a child node
    .._ "Gandalf"              # ... and put some text in it.
console.log gandalf.to-string!
```
```xml
<person profession="wizard"><name>Gandalf</name></person>
```

Shortcut: Create a tag with attributes by passing them as a second argument.

```ls
t = whatxml \tower lean : "3.99"
    .. \place city : "Pisa", country : "Italy"
console.log t.to-string!
```
```xml
<tower lean="3.99"><place city="Pisa" country="Italy"></place></tower>
```

Add self-closing tags and comments too.

```ls
x = whatxml \a
    ..self-closing \b
    ..comment "what"
```
```xml
<a><b /><!--what--></a>
```

Text is escaped automatically, but you can bypass that by calling `raw`. (This
lets you include known text, e.g. from
[`marked`](https://github.com/chjj/marked) or )

```ls
greeting = whatxml \p
  .._ "What's up <3"
console.log greeting.to-string!

x = whatxml \p
  ..raw "<em>I know this is properly escaped already</em>"
console.log x.to-string!
```

```xml
<p>What&#39;s up &#60;3</p>
<p><em>I know this is properly escaped already</em></p>
```

### Templating

You can also pass functions to the setters. Those functions are called with
whatever arguments `toString` was called with, so you can choose their values
based on data:

```ls
link = whatxml \a href : (.href)
  .._ (.name.to-upper-case!)

console.log link.to-string name : \google    href : "https://google.com"
console.log link.to-string name : \runescape href : "http://runescape.com"
```

```xml
<a href="https://google.com">GOOGLE</a>
<a href="http://runescape.com">RUNESCAPE</a>
```

## In summary

 - `.. <string> [<attr-object>]` adds a tag (with optional attributes)
 - `..self-closing <string> [<attr-object>]` same, but self-closing
 - `.. <object>` sets attributes
 - `.._ <string>` adds text
 - `..raw <string>` adds text (without escaping it)
 - `..comment <string>` adds a comment

`toString` renders the tag and, recursively, its child tags too.

## Comment gotchas

If you're going to add XML comments, **it's up to you to provide valid text for
them**!

`whatxml` always generates valid XML and errors if it can't, *with one
exception*: Comment tags may not contain two consecutive hyphens (`--`). That's
just [what the XML spec
says](http://www.w3.org/TR/2006/REC-xml11-20060816/#sec-comments).  Enforcing
that would be inefficient, so `whatxml` doesn't.

## Related libraries

This library wants to be a serious general-purpose [LiveScript]-based
templating engine.

Existing attempts have their flaws:

 - [`live-templ`](https://www.npmjs.org/package/live-tmpl) is the closest to my
   goals, but its objects-in-nested-arrays base is too rigid to handle
   comments, raw text data or self-closing tags. There's no way to combine the
   template with input data.
 - [`create-xml-ls`](https://www.npmjs.org/package/create-xml-ls)' syntax is
   object-based, so it can't even represent two tags with the same name on the
   same level of nesting.
 - [`htmls`](https://www.npmjs.org/package/htmls) supports only the HTML tag
   set and treats template code as a second-class citizen: They're stored as
   strings, later parsed and transformed to actual code, then `eval`'d. (The
   readme makes it very clear that it's a for-fun project though.)

## Try it

It's not on `npm` (yet), but you can clone this repo and

    npm install

then point your `require`s at the root dir.


[LiveScript]: http://livescript.net/
[cascade]: http://livescript.net/#property-access-cascades
