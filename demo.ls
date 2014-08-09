#!/bin/env lsc
whatxml = require \./index.ls

x = whatxml \html
  .. \head
    .. \title ._ "An example"
    ..comment "Secrets!"
  .. \body
    .. \h1
      .. class : "top-heading"
      .._ "An example"
    .. \p
      .._ "Here's a link: "
      .. \a
        .._ "to github"
        .. href : "https://github.com"
      .._ " and some more text after it."
      ..raw "\n<strong>Maybe embed <em>Markdown</em> output here.</strong>\n"
    .. \hr true # self-closing
    .. \p
      .._ "A second paragraph."

console.log x.to-string!
