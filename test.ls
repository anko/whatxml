#!env lsc

# These tests are written with the [tape][1] module, which produces output in a
# standardised protocol called [Test Anything Protocol (TAP)][2].  This
# occupies stdout, so if you need to print some diagnostics, you might want to
# log to stderr or to open a log file.
#
# Various [TAP-consuming programs exist][3], some of which prettify test
# results for you. [faucet][4] is nice.
#
# [1]: https://www.npmjs.org/package/tape
# [2]: http://testanything.org/
# [3]: http://testanything.org/consumers.html
# [4]: https://www.npmjs.org/package/faucet

test = (name, func) ->
  (require \tape) name, (t) ->
    func.call t   # Make `this` refer to tape's asserts
    t.end!        # Automatically end tests


whatxml = require "./index.ls"

test "errors on bad tag name" ->
  [ (-> whatxml true)
    (-> whatxml {})
    (-> whatxml ->) ].map (`@throws` Error)

test "tag nesting" ->
  whatxml \outer
    .. \b
    .. \c
      .. \d
    .. \e
    ..to-string! `@equals` "<outer>
                              <b></b>
                              <c><d></d></c>
                              <e></e>
                            </outer>"

test "comments" ->
  whatxml \anything
    ..comment "Ninjas were here!"
    ..to-string! `@equals` "<anything>
                              <!--Ninjas were here!-->
                            </anything>"

test "adding attributes when constructing tag" ->
  whatxml \a id : \gh-link
    ..to-string! `@equals` "<a id=\"gh-link\"></a>"

test "adding attributes with `attr` call" ->
  whatxml \a
    ..attr \id \gh-link
    ..to-string! `@equals` "<a id=\"gh-link\"></a>"
test "adding attributes by calling with object" ->
  whatxml \a
    .. id : \gh-link
    ..to-string! `@equals` "<a id=\"gh-link\"></a>"

test "attributes are overwritten if set again" ->
  whatxml \srw
    .. track : "Ace Attacker"
    .. track : "Trombe!"
    ..to-string! `@equals` "<srw track=\"Trombe!\"></srw>"

test "setting a non-existent attr to false, null or undefined does nothing" ->
  [ false, null, undefined ].for-each ~>
    whatxml \a
      .. x : it
      ..to-string! `@equals` "<a></a>"
test "attributes are overwritten if set to false, null or undefined" ->
  [ false, null, undefined ].for-each ~>
    whatxml \a
      .. x : \hi
      .. x : it
      ..to-string! `@equals` "<a></a>"
test "templates can also set attributes false, null or undefined" ->
  templ = -> return it # identity function
  [ false, null, undefined ].for-each ~>
    whatxml \a
      .. x : "hi"
      .. x : templ
      ..to-string it
        .. `@equals` "<a></a>"

test "attributes with empty strings are OK" ->
  whatxml \a x : ""
    ..to-string! `@equals` "<a x=\"\"></a>"

test "text is appended if set again" ->
  whatxml \greeting
    .._ "Hello "
    .._ "world!"
    ..to-string! `@equals` "<greeting>Hello world!</greeting>"

test "comments are always appended even if called again" ->
  whatxml \x
    ..comment "a"
    ..comment "b"
    ..to-string! `@equals` "<x><!--a--><!--b--></x>"
test "comments are always appended even if called again" ->
  whatxml \x
    ..comment "a"
    ..comment "b"
    ..to-string! `@equals` "<x><!--a--><!--b--></x>"
test "raw text is always appended even if called again" ->
  whatxml \x
    ..raw "a"
    ..raw "b"
    ..to-string! `@equals` "<x>ab</x>"

test "adding standalone attribute" ->
  whatxml \input selected : true
    ..to-string! `@equals` "<input selected></input>"

test "adding text" ->
  whatxml \p
    .._ "whatever text"
    ..to-string! `@equals` "<p>whatever text</p>"

test "self-closing tags" ->
  whatxml \a
    ..self-closing \b
    ..to-string! `@equals` "<a><b /></a>"

test "self-closing tag attributes" ->
  whatxml \a
    ..self-closing \b hi : \there
    ..to-string! `@equals` "<a><b hi=\"there\" /></a>"

test "self-closing tag can't have children" ->
  whatxml \a
    ..self-closing \b
      .. \c `@throws` Error

test "self-closing root tag" ->
  whatxml.self-closing \a attr : \b
    ..to-string! `@equals` "<a attr=\"b\" />"

test "content text escaping" ->
  whatxml \a
    .._ "x < y"
    ..to-string! `@equals` "<a>x &\#x3C; y</a>"

test "raw content text" ->
  whatxml \a
    ..raw "<stuff attr=\"a\">within</stuff>"
    ..to-string! `@equals` "<a><stuff attr=\"a\">within</stuff></a>"

test "can have multiple top-level tags" ->
  whatxml!
    .. \a
    .. \b
    ..to-string! `@equals` "<a></a><b></b>"

test "anonymous top-level tag can't have attributes" ->
  (-> whatxml! attr : "hi") `@throws` Error

test "anonymous-top-level tag can have text too" ->
  whatxml!
    ..comment "hi"
    .._ "text"
    ..raw "<hr />"
    .. \a
    ..to-string! `@equals` "<!--hi-->text<hr /><a></a>"

test "attributes are templateable" ->
  whatxml \a
    .. test : -> it # identity function
    ..to-string "hi"
      .. `@equals` "<a test=\"hi\"></a>"

test "texts are templateable" ->
  whatxml \a
    .._ -> it # identity function
    ..to-string "hi"
      .. `@equals` "<a>hi</a>"

test "comments are templateable" ->
  whatxml \a
    ..comment -> it # identity function
    ..to-string "hi"
      .. `@equals` "<a><!--hi--></a>"

test "templates work in nested contexts" ->
  whatxml \html
    .. \head
      .. \title ._ (.title)
    .. \body
      .. \div id : \content
        .. \h1 ._ (.title)
        ..raw (.content)

    ..to-string title : "Blog post" content : "<p>Look, I write!</p>"
      .. `@equals` "<html>
                      <head><title>Blog post</title></head>
                      <body>
                        <div id=\"content\">
                          <h1>Blog post</h1>
                          <p>Look, I write!</p>
                        </div>
                      </body>
                    </html>"

test "templates are reusable" ->
  book = whatxml \book
    .. year : (.year)
    .. \title  ._ (.title)
    .. \author ._ (.author)

  b1 = book.to-string title : "Hack This!" author : "Jon Baichtal" year : "2013"
    .. `@equals` "<book year=\"2013\"><title>Hack This!</title><author>Jon Baichtal</author></book>"

  b2 = book.to-string title : "Neuromancer" author : "William Gibson" year : "1984"
    .. `@equals` "<book year=\"1984\"><title>Neuromancer</title><author>William Gibson</author></book>"

test "templates are reusable, also with less attributes later" ->
  character = whatxml \vocaloid name : (.name), scarf : (.scarf)
  character
    ..to-string { name : "KAITO", scarf : \blue }
      .. `@equals` "<vocaloid name=\"KAITO\" scarf=\"blue\"></vocaloid>"
    ..to-string { name : "Hatsune Miku" }
      .. `@equals` "<vocaloid name=\"Hatsune Miku\"></vocaloid>"
