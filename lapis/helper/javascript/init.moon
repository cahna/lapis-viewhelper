
import encode from require "cjson"
import insert, concat from table

make_js_block = (code) ->
  if type code == "string"
    return "<script type=\"text/javascript\">#{code}</script>"

make_onready_block = (snippets) ->
  if snippets and #snippets > 0
    code = concat(snippets, "")
    make_js_block "$(document).ready(function() { #{code} });\n"

class JavascriptHelper
  new: =>
    @snippets = {}
    @on_ready = {}

  add_snippet: (code) =>
    if code and type(code) == "string"
      insert @snippets, code

  add_on_ready: (code) =>
    if code and type(code) == "string"
      insert @on_ready, code

  add_form_validator: (selector, rules) =>
    return unless selector

    vrules = if rules and type rules == "table"
        rules
      else
        {}

    @add_on_ready "$('#{selector}').validate({
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

  footer_scripts: =>
    blocks = ""
    blocks ..= make_js_block(snip) for snip in *@snippets
    ready = make_onready_block(@on_ready) or ""

    blocks .. ready

