
import encode from require "cjson"
import insert, concat from table

cdn = {
  google: "//ajax.googleapis.com/ajax/libs/jquery/%s/jquery.min.js"
  jquery: "//code.jquery.com/jquery-%s.min.js"
  microsoft: "//ajax.aspnetcdn.com/ajax/jQuery/jquery-%s.min.js"
  cdnjs: "//ajax.aspnetcdn.com/ajax/jQuery/jquery-%s.min.js"
}

-- TODO: Make defaults configurable within lapis config
DEFAULT_CDN = cdn.google
DEFAULT_VERSION = "1.10.2"

class JqueryHelper
  --
  -- A JqueryHelper must be given an existing JsHelper when created.
  -- Optionally, include a version of jQuery
  --
  -- opt: {
  --   src: "/path/to/local/jquery.js"
  --   include: [true|false] or "the.jquery.version"
  --   cdn: "(google|jquery|microsoft|cdnjs)" or "/custom/scripts/dir/jquery-%s.js"
  --   extras: { url_1, url_2, ... }
  -- }
  --
  new: (js_helper, opt = false) =>
    @js_helper = js_helper
    @include = false

    -- Handle extended usage
    if opt
      if opt.src and type opt.src == "string"
        @include = opt.src
      elseif opt.include
        tmpl = DEFAULT_CDN
        ver = DEFAULT_VERSION

        -- Set the cdn URL
        if opt.cdn and cdn[opt.cdn]
          -- A predefined CDN from above
          tmpl = cdn[opt.cdn]
        elseif type opt.cdn == "string"
          -- Interpret the string as a format string like CDN's above
          tmpl = opt.cdn

        -- Interpret an opt.include string as a version specifier to mash with the cdn/src format string
        if type opt.include == "string"
          ver = opt.include

        @include = tmpl\format version

      @js_helper\lib @include if @include

      if opt.extra and type opt.extra == "table"
        @js_helper\lib e for e in *opt.extras

  -- Wrap a js code snippet with $(document).ready(...) and add to body's js code cache
  ready: (code) =>
    snippet = "$(document).ready(function(){\n#{code}\n});"
    @js_helper\block snippet

  -- Add form validation with jquery.validator (you must include that library yourself)
  form_validator: (selector, rules) =>
    return unless selector

    vrules = if rules and type rules == "table"
        rules
      else
        {}

    @ready "$('#{selector}').validate({
      rules: #{encode vrules},
      showErrors: function(errorMap, errorList) {

        /* Clean up any tooltips for valid elements */
        $.each(this.validElements(), function (index, element) {
          var $element = $(element);
          $element.data('title', '')
            .tooltip('destroy');
          $element.closest('.input-group').removeClass('has-error').addClass('has-success');
        });

        /* Create new tooltips for invalid elements */
        $.each(errorList, function (index, error) {
          var $element = $(error.element);
          $element.tooltip('destroy')
            .data('title', error.message)
            .data('container', 'body')
            .data('placement', 'left')
            .data('trigger', 'manual')
            .tooltip()
            .tooltip('show');
          $element.closest('.input-group').addClass('has-error');
        });
      }
    });"

