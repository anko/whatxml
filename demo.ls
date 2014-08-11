#!/bin/env lsc
whatxml = require \./index.ls

x = whatxml \html
  .. \head
    .. \title ._ "An example"
    ..comment "Secrets!"
  .. \body
    .. \h1 class : "top-heading" ._ "An example"
    .. \p
      .._ "Here's a link: "
      .. \a href : "https://github.com" ._ "to github"
      .._ " and some more text after it."
      ..raw "\n<strong>Maybe embed <em>Markdown</em> output here.</strong>\n"
    ..self-closing \hr
    .. \p ._ "A second paragraph."

console.log x.to-string!

greeting = whatxml \p
  .._ "What's up <3"
console.log greeting.to-string!

link = whatxml \a href : (.href)
  .._ (.name.to-upper-case!)

console.log link.to-string name : \google    href : "https://google.com"
console.log link.to-string name : \runescape href : "http://runescape.com"
