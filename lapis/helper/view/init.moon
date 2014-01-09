
js = require "lapis.helper.view.javascript"
css = require "lapis.helper.view.css"

class ViewHelper
  new: =>
    @js = js!
    @css = css!

