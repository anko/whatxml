#!env lsc

test = (name, test-func) ->
  (require \tape) name, (t) ->

    # Make `this` refer to tape's asserts
    test-func.call t

    # Automatically end tests
    t.end!


whatxml = require "./index.ls"

test "wants string name" ->
    (-> whatxml!) `@throws` Error
    (-> whatxml true) `@throws` Error

test "nesting" ->
    x = whatxml \outer
      .. \b
      .. \c
        .. \d
      .. \e
    x.to-string! `@equals` "<outer>
                              <b></b>
                              <c><d></d></c>
                              <e></e>
                            </outer>"

test "comments" ->
  x = whatxml \anything
    ..comment "Ninjas were here!"
  x.to-string! `@equals` "<anything>
                            <!--Ninjas were here!-->
                          </anything>"

test "adding attributes in tag spec" ->
  x = whatxml \a id : \gh-link .to-string!
  x.to-string! `@equals` "<a id=\"gh-link\"></a>"
test "adding attributes by calling `attr`" ->
  x = whatxml \a
    ..attr \id \gh-link
  x.to-string! `@equals` "<a id=\"gh-link\"></a>"
test "adding attributes by calling with object" ->
  x = whatxml \a
    .. id : \gh-link
  x.to-string! `@equals` "<a id=\"gh-link\"></a>"

test "adding text" ->
  x = whatxml \p
    .._ "whatever text"
  x.to-string! `@equals` "<p>whatever text</p>"

test "self-closing tags" ->
  x = whatxml \a
    ..self-closing \b
  x.to-string! `@equals` "<a><b /></a>"

test "content text escaping" ->
  x = whatxml \a
    .._ "x < y"
  x.to-string! `@equals` "<a>x &\#x3C; y</a>"

test "raw content text" ->
  x = whatxml \a
    ..raw "<stuff attr=\"a\">within</stuff>"
  x.to-string! `@equals` "<a><stuff attr=\"a\">within</stuff></a>"

test "attributes are templateable" ->
  x = whatxml \a
    .. test : -> it # identity function
  (x.to-string "hi") `@equals` "<a test=\"hi\"></a>"

test "texts are templateable" ->
  x = whatxml \a
    .._ -> it # identity function
  (x.to-string "hi") `@equals` "<a>hi</a>"

test "comments are templateable" ->
  x = whatxml \a
    ..comment -> it # identity function
  (x.to-string "hi") `@equals` "<a><!--hi--></a>"

test "templates are nestable" ->
  page = whatxml \html
    .. \head
      .. \title ._ (.title)
    .. \body
      .. \div id : \content
        .. \h1 ._ (.title)
        ..raw (.content)

  rendered-page = page.to-string title : "Blog post" content : "<p>Look, I write!</p>"
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
