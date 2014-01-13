
import render_html from require "lapis.html"
import encode from require "cjson"
import insert, concat from table

-- If within a lapis development environment, JsHelper can give
-- warning/error messages to the browser's javascript console
config = require("lapis.config").get!
_debug = config._name == "development"

wrap = (code) ->
--  return render_html ->
--    script type: "text/javascript", ->
--      raw code
  "<script type=\"text/javascript\">#{code}</script>"

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

--  render_html ->
--    script type: "text/javascript", src: url

  "<script src=\"#{url}\" />"

class JsZone
  new: =>
    @_js = blocks: {}, urls: { libs: {}, others: {} }

  add_block: (code) =>
    insert @js.blocks, script_block code

  add_src: (url) =>
    insert @_js.urls.others, script_src url

  add_lib: (url) =>
    insert @_js.urls.libs, script_src url

  render: =>
    libs = concat @_js.urls.libs, "\n"
    others = concat @_js.urls.others, "\n"
    blocks = concat @_js.blocks, "\n"

    libs .. others .. blocks

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
    "#{@head\render!}\n#{@body\render!}\n"

