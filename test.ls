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
    ..attr \class \gh-link
    ..attr \href "https://github.com"
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

