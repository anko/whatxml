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

test "adding attributes and text" ->
  x = whatxml \a
    .. class : \gh-link               # style 1; feel free to pass many if
                                      #   their order in output is irrelevant
    ..attr \href "https://github.com" # style 2
    .._ "to Github"
  x.to-string! `@equals` "<a class=\"gh-link\" href=\"https://github.com\">
                            to Github
                          </a>"

test "self-closing tags" ->
  x = whatxml \a
    .. \b true
  x.to-string! `@equals` "<a><b /></a>"

test "content text escaping" ->
  x = whatxml \a
    .._ "x < y"
  x.to-string! `@equals` "<a>x &#60; y</a>"

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
      .. \div
        .. id : \content
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
