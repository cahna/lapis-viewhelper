
js = require "lapis.helper.view.javascript"
--css = require "lapis.helper.view.css"
jquery = require "lapis.helper.view.jquery"

class ViewHelper
  new: =>
    @js = js!
--    @css = css!
    @jquery = jquery @js

