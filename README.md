
lapis.helper.javascript
=======================

Provide javascript snippets from anywhere within a lapis request to be 
included within the page's layout.

## Usage ##

This is how I use this in my projects.

__web.moon__: Require the helper in your application, then instantiate a new instance of the helper
within your application.

```moonscript
lapis = require "lapis"
js = require "lapis.helper.javascript"

import generate_token from require "lapis.csrf"

class MyApp extends lapis.Application
  layout: require "views.my_view"

  @before_filter =>
    @csrf_token = generate_token @

    -- Load helpers that cache things to be rendered in the layout
    @JsHelper = js!

  -- Routes:
  [index: "/"]: =>
    @page_title = "A javascript helper for lapis"
    render: true

```

__views/index.moon__: Use the `@JsHelper` instantiated above to register some js for the page's layout.

```moonscript
import Widget from require "lapis.html"

class Index extends Widget
  content: =>
    div class: "row", ->
      div class: "panel panel-primary", ->
        div class: "panel-heading", ->
          h1 "Join MySite"
        
        div class: "panel-body", ->
          -- User register form
          form id: "register-form", class: "form-horizontal", method: "POST", action: @url_for("user_register"), ->
            input type: "hidden", name: "csrf_token", value: @csrf_token
            fieldset class: "col-sm-12", ->
              -- ...The form goes here...

    -- Register the needed javascript to be included in the layout (this example implements the jquery.validate library)
    @JsHelper\add_form_validator "#register-form", {
      username:         { required: true, minlength: 2, maxlength: 25 }
      email:            { required: true, email: true }
      password:         { required: true, minlength: 8 }
      password_confirm: { required: true, equalTo: "input[name=password]"}
      agree_terms:      { required: true }
    }
```

__views/my_view.moon__: Render the cached javascript blocks in the layout.

```moonscript
import Widget from require "lapis.html"

class MyView extends Widget
  content: =>
    html_5 ->
      head ->
        meta charset: "utf-8"
        meta name: "viewport", content: "width=device-width, initial-scale=1.0"
        
        title ->
          text @page_title
        
        -- and other header stuff...

      body ->
        -- Insert page's contents from app route and/or the route's associated widget
        @content_for "inner"

        -- Javascript (yea, the helper *could* control this but I haven't needed that yet)
        script src: "/static/js/jquery-1.10.2.js"
        script src: "/static/js/bootstrap.js"
        script src: "/static/js/jquery.validate.min.js"

        -- Add cached script blocks
        raw @JsHelper\footer_scripts!

```

## Status ##

I'm currently hacking this together to provide features I need whenever
I find that I need them. I would like this to become a less-hacky module
that can be used with ease and confidence along with lapis. Contributions
and/or requests are welcome.

