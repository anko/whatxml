# whatxml

`(X|HT|XHT)ML` templating with [LiveScript]'s [cascade] syntax.

## Examples

```
x = whatxml \html
  .. \head
    .. \title ._ "Example title"
    ..comment "Secrets!"
  .. \body
    .. \h1 class : "top-heading" ._ "Example heading"
    .. \p
      .._ "Here's a link: "
      .. \a href : "https://github.com" ._ "to github"
      .._ " and some more text after it."
      ..raw "\n<strong>Maybe embed <em>Markdown</em> output here.</strong>\n"
    ..self-closing \hr
    .. \p ._ "A second paragraph."

console.log x.to-string!
```

```
<html><head><title>An example</title><!--Secrets!--></head><body><h1 class="top-heading">An example</h1><p>Here&#39;s a link: <a href="https://github.com">to github</a> and some more text after it.
<strong>Maybe embed <em>Markdown</em> output here.</strong>
</p><hr /><p>A second paragraph.</p></body></html>
```

Text is HTML-escaped with [`ent`](https://www.npmjs.org/package/ent):

```
greeting = whatxml \p
  .._ "What's up <3"
console.log greeting.to-string!
```

```
<p>What&#39;s up &#60;3</p>
```

You can also pass functions to the various setters. Those functions are called
with the arguments to `toString` when rendering, to derive their final values:

```
link = whatxml \a href : (.href)
  .._ (.name.to-upper-case!)

console.log link.to-string name : \google    href : "https://google.com"
console.log link.to-string name : \runescape href : "http://runescape.com"
```

```
<a href="https://google.com">GOOGLE</a>
<a href="http://runescape.com">RUNESCAPE</a>
```

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

Then point your `require`s at the root dir.


[LiveScript]: http://livescript.net/
[cascade]: http://livescript.net/#property-access-cascades
