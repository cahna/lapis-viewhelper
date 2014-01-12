
import render_html from quire "lapis.html"
import encode from require "cjson"
import insert, concat from table

-- If within a lapis development environment, JsHelper can give
-- warning/error messages to the browser's javascript console
config = require("lapis.config").get!
_debug = config._name == "development"

wrap = (code) ->
  render_html ->
    script type: "text/javascript", ->
      code

warn_msg = (msg, data) ->
  if _debug
    return wrap "console.log('JsHelper Warning: #{msg} [#{data}]);"
  else
    return ""

script_block = (code) ->
  unless type code == "string"
    return warn_msg code

  wrap code

script_src = (url) ->
  unless type url == "string"
    return warn_msg url

  render_html ->
    script type: "text/javascript", src: url

class JsZone
  new: =>
    @js = blocks: {}, urls: { libs: {}, others: {} }

  add_block: (code) =>
    insert @js.blocks, script_block code

  add_src: (url) =>
    insert @js.urls.others, script_src url

  add_lib: (url) =>
    insert @js.urls.libs, script_src url

  render: =>
    libs = l for l in *@js.urls.libs
    others = o for o in *@js.urls.others
    blocks = b for b in *@js.blocks

    "#{libs}\n#{others}\n#{blocks}"

class JsHelper
  -- Create the render zones
  new: =>
    -- Access these directly if you'd like with @JsHelper.head\foo(...)
    @head = JsZone!
    @body = JsZone!

  -- Add a script block to the body cache
  block: (code) =>
    return unless type code == "string"
    @body\add_block, code

  -- Add url to js source (control whether to add to head or body cache with 2nd parameter)
  src: (url, is_lib = false) =>
    return unless type url == "string"

    if is_lib
      @head\add_src url
    else
      @body\add_src url

  -- A lib is just a source file with higher priority (so long as you render the scripts in the proper place within your view)
  lib: (name, url) =>
    @src name, url, true

  -- Shortcut to render all scripts in one shot (rather than accessing @JsHelper.(head|body)\render! directly
  render: =>
    @head\render! .. @body\render!

