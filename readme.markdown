# whatxml

DRY `(X|HT|XHT)ML` templating with [LiveScript][1]'s [cascade][2] syntax.

    npm install whatxml

## Basically

You write

```ls
x = whatxml \html
    .. \head
        .. \title ._ "My page"
        ..self-closing \link rel : \stylesheet type : \text/css href : \main.css
    .. \body
        .. \p ._ "Here's a paragraph."

console.log x.to-string!
```

and you get

```html
<html><head><title>My page</title><link rel="stylesheet" type="text/css" href="main.css" /></head><body><p>Here&#x27;s a paragraph.</p></body></html>
```

You can also pass a function to anything and decide its based on what's passed
in to the `to-string` call, a lot like `.attr` in [D3][3]. (Read on for the
details.)

## API summary

 - `.. <string> [<attr-object>]` adds a tag (with optional attributes)
 - `..self-closing <string> [<attr-object>]` same, but self-closing
 - `.. <object>` sets attributes
 - `.._ <string>` adds text
 - `..raw <string>` adds text (without escaping it)
 - `..comment <string>` adds a comment

`toString` renders the tag and, recursively, its child tags too.

## API tutorial

### Basics

Make a root tag.

```ls
p = whatxml \person
console.log p.to-string!
```
```xml
<person></person>
```

- - -

Call it with a `string` to create child tags, with an `object` to add
attributes or call `_` to add text between the tags.

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

- - -

*Shortcut*: Pass object of attributes as second argument when creating a tag.

```ls
t = whatxml \tower lean : "3.99"
    .. \place city : "Pisa", country : "Italy"
console.log t.to-string!
```
```xml
<tower lean="3.99"><place city="Pisa" country="Italy"></place></tower>
```

- - -

You can add `self-closing` tags and `comment`s too.

```ls
x = whatxml \a
    ..self-closing \b
    ..comment "what"
```
```xml
<a><b /><!--what--></a>
```

- - -

All text is escaped automatically, but you can bypass that by calling `raw`.
(This lets you include text you know is escaped already, e.g. from
[`marked`][4]

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

To generate content based on data, you can also pass a function to any setter
call. When `toString` is called on a tag, the functions passed before are
called with those arguments.

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

## Limitations

If you're going to add XML comments, **make sure they're valid text**: Comment
tags may not contain two consecutive hyphens (`--`). [The XML spec requires
it][5]. For performance reasons, `whatxml` doesn't enforce that.

## Related libraries

This library wants to be a serious general-purpose [LiveScript]-based
templating engine.

Existing attempts have their flaws:

 - [`live-templ`][6] is the closest to my goals, but its
   objects-in-nested-arrays base is too rigid to handle comments, raw text data
   or self-closing tags. It provides no way to combine the template with input
   data.
 - [`create-xml-ls`][7]' syntax is object-based: It can't represent two tags
   with the same name on the same level of nesting…
 - [`htmls`][8] supports only the HTML tag set and treats template code as a
   second-class citizen: They're stored as strings, later parsed and
   transformed to actual code, then `eval`'d. (The readme makes it very clear
   it's a for-fun project though.)


[1]: http://livescript.net/
[2]: http://livescript.net/#property-access-cascades
[3]: http://d3js.org/
[4]: https://github.com/chjj/marked
[5]: http://www.w3.org/TR/2006/REC-xml11-20060816/#sec-comments
[6]: https://www.npmjs.org/package/live-tmpl
[7]: https://www.npmjs.org/package/create-xml-ls
[8]: https://www.npmjs.org/package/htmls
