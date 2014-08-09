{ obj-to-pairs, map, unwords } = require \prelude-ls
require! \ent

class TextNode
  (@data) ->
  to-string : -> ent.encode @data
class RawNode
  (@data) ->
  to-string : -> @data
class CommentNode
  (@data) ->
  to-string : -> "<!--#{ent.encode @data}-->"

module.exports = new-node = (name, self-closing=false) ->

  throw Error "Tag name must be a String" unless typeof name is \string

  attributes = {}
  children   = []

  complain = -> throw new Error "Self-closing nodes may not have children"

  add-child = (name, new-self-closing=false) ->
    complain! if self-closing
    n = new-node name, new-self-closing
      children.push ..

  add-text    = -> complain! if self-closing ; children.push new TextNode it
  add-raw     = -> complain! if self-closing ; children.push new RawNode it
  add-comment = -> complain! if self-closing ; children.push new CommentNode it

  set-attribute     = (k, v=true) -> attributes[k] = v
  import-attributes = -> attributes <<< it

  render = (input) ->

    # Resolve function-containing attributes
    resolved-attributes = ^^attributes
    for k, v of resolved-attributes
      if typeof v is \function
        resolved-attributes[k] = input |> v

    # Resolve function-containing children
    resolved-children = children.map ->
      ^^it
        ..data = input |> it.data if typeof it.data is \function

    s-attributes = resolved-attributes
      |> obj-to-pairs
      |> map ([key,value]) ->
        | value is true => key                              # lone key
        | otherwise     => "#key=\"#{ent.encode value}\""   # valued key
      |> unwords
    # Prepend space if necessary
    if s-attributes.length then s-attributes = " #s-attributes"

    s-children = resolved-children.map (.to-string input) .reduce (+), ""

    if self-closing then "<#name#s-attributes />"
    else                 "<#name#s-attributes>#s-children</#name>"


  base = (first-arg) ->
    ( switch typeof first-arg
      | \string => add-child
      | \object => import-attributes ).apply this, arguments

  base
    .._         = add-text
    ..raw       = add-raw
    ..comment   = add-comment
    ..attr      = set-attribute
    ..to-string = render
