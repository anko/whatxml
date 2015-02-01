{ obj-to-pairs, map, unwords, Obj : map : objmap }  = require \prelude-ls
require! \he

new-tag = (name, attributes={} self-closing=false) ->

  throw Error "Tag name must be a String" unless typeof name is \string

  attributes = ^^attributes
  children   = []

  complain = -> throw new Error "Self-closing nodes may not have children"

  content-node = (render) ->
    (value) ->
      (template-data) ->
        | typeof value is \function => render value template-data
        | _ => render value

  text-node    = content-node -> he.encode it
  raw-node     = content-node -> it # identity
  comment-node = content-node -> "<!--#{he.encode it}-->"

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
    ..add-text    = -> complain! if self-closing ; children.push text-node it
    ..add-raw     = -> complain! if self-closing ; children.push raw-node it
    ..add-comment = -> complain! if self-closing ; children.push comment-node it
    ..set-attribute     = (k, v=true) -> attributes[k] = v
    ..import-attributes = -> attributes <<< it
    ..add-child = (name, attributes) ->
      complain! if self-closing
      n = new-tag name, attributes, false
        children.push ..
    ..add-child-self-closing = (name, attributes) ->
      complain! if self-closing
      n = new-tag name, attributes, true
        children.push ..

wrap = (node) ->
  base = (first-arg) ->
    switch typeof first-arg
      | \string =>
        wrap (node.add-child .apply this, arguments)
      | \object =>
        node.import-attributes .apply this, arguments
        return base

  base
    ..to-string = -> node it
    .._ = node.add-text
    ..raw = node.add-raw
    ..attr = node.set-attribute
    ..comment = node.add-comment
    ..self-closing = node.add-child-self-closing


module.exports = construct = (name, attributes, self-closing) ->
  wrap new-tag.apply this, arguments
