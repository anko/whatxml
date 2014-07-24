#!/bin/env lsc
require! \./whatxml.ls

x = whatxml \html
  .. \head
    .. \title ._ "An example"
    ..comment "Secrets!"
  .. \body
    .. \h1
      ..attr "class" "top-heading"
      .._ "An example"
    .. \p
      .._ "Here's a link: "
      .. \a
        .._ "to github"
        ..attr \href "https://github.com"
      .._ " and some more text after it."
      ..raw "\n<strong>Raw text is <em>great</em> for markdown output.</strong>\n"
    .. \hr true # self-closing
    .. \p
      .._ "A second paragraph."

console.log x.to-string!
