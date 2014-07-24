{ obj-to-pairs, map, unwords } = require \prelude-ls
require! \ent

class TextNode
  (@data) ->
  to-string : -> ent.encode @data
class CommentNode
  (@data) ->
  to-string : -> "<!--#{ent.encode @data}-->"

module.exports = new-node = (name, self-closing=false) ->

  attributes = {}
  children = []

  add-element = (name, new-self-closing=false) ->
    if self-closing
      throw new Error "Self-closing node can't contain other nodes"
    n = new-node name, new-self-closing
    children.push n
    n

  add-element
    .._ = ->
      if self-closing
        throw new Error "Self-closing node can't contain text"
      children.push new TextNode it
    ..raw = ->
      if self-closing
        throw new Error "Self-closing node can't contain raw text"
      children.push it
    ..comment = ->
      if self-closing
        throw new Error "Self-closing node can't contain a comment"
      children.push new CommentNode it
    ..attr = (key, value=true) -> attributes[key] = value
    ..to-string = ->
      attributes-string = obj-to-pairs attributes
        |> map ([key,value]) ->
          if value is true then key             # standalone key
          else "#key=\"#{ent.encode value}\""   # key with value
        |> unwords
      children-string = children.map (.to-string!) .reduce (+), ""
      attributes-string = if attributes-string.length
        then " #attributes-string" else ""
      if self-closing
        "<#name#attributes-string />"
      else
        "<#name#attributes-string>#children-string</#name>"
