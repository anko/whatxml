{
  obj-to-pairs, map, unwords,
  Obj: { map : obj-map, filter : obj-filter }
} = require \prelude-ls
{ encode } = require \he # character entity coding

# Internal tag abstraction
# ------------------------
# Each is a closure with methods for modifying its attributes or adding child
# tags or other content.
new-tag = (name, init-attributes={} type={}) ->

  anonymous    = type.anonymous    || false
  self-closing = type.self-closing || false

  if not anonymous and typeof name isnt \string
    throw Error "Tag name must be a String"

  attributes = []
  children   = []

  keep-attribute-value = (not in [ false null undefined ])

  set-attribute = (k, v) ->
    throw new Error "Anonymous tags may not have attributes" if anonymous
    if keep-attribute-value v then attributes[k] = v
    else delete attributes[k]
  import-attributes = -> for k,v of it then set-attribute k, v

  import-attributes init-attributes

  content = (
    render        # function for rendering value to string
    value         # value to render (or a template function)
    template-data # data passed when templating
  ) --> | typeof value is \function => template-data |> value |> render
        | otherwise                 => value |> render

  text-content    = content -> encode it
  raw-content     = content -> it # identity
  comment-content = content -> "<!--#{encode it}-->"

  render = (input) ->

    s-children = children .map (-> it input) .join ""

    if anonymous then s-children
    else
      # Resolve function-containing attributes
      s-attributes = attributes
        |> obj-map ->
          | typeof it is \function =>
            v = it input
            if keep-attribute-value v then v else undefined
          | otherwise =>
            switch
            | typeof it is \boolean => it
            | typeof it isnt \string =>
              throw Error "Unexpected non-string attribute `#it`"
            | otherwise => it
        |> obj-filter (?)
        |> obj-to-pairs
        |> map ([key,value]) ->
          | value is true => key                        # lone key
          | otherwise     => "#key=\"#{encode value}\"" # valued key
        |> unwords

      # Prepend space if necessary
      if s-attributes.length then s-attributes = " #s-attributes"

      if self-closing then "<#name#s-attributes />"
      else                 "<#name#s-attributes>#s-children</#name>"

  die-if-self-closing = ->
    throw new Error "Self-closing tags may not have children" if self-closing

  render
    ..add-text    = -> die-if-self-closing! ; children.push text-content it
    ..add-raw     = -> die-if-self-closing! ; children.push raw-content it
    ..add-comment = -> die-if-self-closing! ; children.push comment-content it
    ..set-attribute     = set-attribute
    ..import-attributes = import-attributes
    ..add-child = ->
      die-if-self-closing!
      new-tag.apply null, arguments
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
      | \string => wrap tag.add-child &0, &1
      | \object => tag.import-attributes ...
      | otherwise =>
        throw Error "Expected string or object argument to tag creation" )
    ..to-string    = tag                       .bind!
    .._            = tag.add-text              .bind!
    ..raw          = tag.add-raw               .bind!
    ..attr         = tag.set-attribute         .bind!
    ..comment      = tag.add-comment           .bind!
    ..self-closing = -> wrap tag.add-child &0, &1, { +self-closing }

module.exports = ((first-arg)->
  if typeof first-arg is \undefined
    wrap new-tag &0, &1, { +anonymous }
  else
    wrap new-tag &0, &1 )
  ..self-closing = -> wrap new-tag &0, &1, { +self-closing }
