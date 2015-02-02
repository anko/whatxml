{ obj-to-pairs, map, unwords, Obj : map : objmap }  = require \prelude-ls
require! \he

# Internal tag abstraction
# ------------------------
# Each is a closure with methods for modifying its attributes or adding child
# tags or other content.
new-tag = (name, attributes={} self-closing=false) ->

  throw Error "Tag name must be a String" unless typeof name is \string

  attributes = ^^attributes
  children   = []

  die-if-self-closing = ->
    throw new Error "Self-closing tags may not have children" if self-closing

  content = (
    render        # function for rendering value to string
    value         # value to render (or a template function)
    template-data # data passed when templating
  ) -->
    | typeof value is \function => template-data |> value |> render
    | otherwise                 => value |> render

  text-content    = content -> he.encode it
  raw-content     = content -> it # identity
  comment-content = content -> "<!--#{he.encode it}-->"

  render = (input) ->

    # Resolve function-containing attributes
    s-attributes = attributes
      |> objmap ->
        | typeof it is \function => it input
        | otherwise              => it
      |> obj-to-pairs
      |> map ([key,value]) ->
        | value is true => key                           # lone key
        | otherwise     => "#key=\"#{he.encode value}\"" # valued key
      |> unwords
    # Prepend space if necessary
    if s-attributes.length then s-attributes = " #s-attributes"

    s-children = children .map (-> it input) .reduce (+), ""

    if self-closing then "<#name#s-attributes />"
    else                 "<#name#s-attributes>#s-children</#name>"

  render
    ..add-text    = -> die-if-self-closing! ; children.push text-content it
    ..add-raw     = -> die-if-self-closing! ; children.push raw-content it
    ..add-comment = -> die-if-self-closing! ; children.push comment-content it
    ..set-attribute     = (k, v=true) -> attributes[k] = v
    ..import-attributes = -> attributes <<< it
    ..add-child = (name, attributes) ->
      die-if-self-closing!
      new-tag name, attributes, false
        children.push ..
    ..add-child-self-closing = (name, attributes) ->
      die-if-self-closing!
      new-tag name, attributes, true
        children.push ..

# World-exposed API
# -----------------
# This delegates to the internal API, but rearranges/abbreviates it for
# user-friendliness. The methods are bound to make sure the internal
# abstraction can't leak and to document that their `this`-context doesn't
# matter.
wrap = (tag) ->
  ((first-arg) ->
    switch typeof first-arg
      | \string => wrap tag.add-child ...
      | \object => tag.import-attributes ... ; this )
    ..to-string    = tag                       .bind!
    .._            = tag.add-text              .bind!
    ..raw          = tag.add-raw               .bind!
    ..attr         = tag.set-attribute         .bind!
    ..comment      = tag.add-comment           .bind!
    ..self-closing = tag.add-child-self-closing.bind!

module.exports = wrap << new-tag
