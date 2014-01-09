
require "lapis.helper.view"
=================================

Register JavaScript & CSS blocks at multiple locations within a Lapis request to be rendered in a page's layout.

## Usage ##

This is how I use this in my projects.

__web.moon__: Require the helper in your application, then instantiate a new instance of the helper
within your application.

```moonscript
lapis = require "lapis"
viewh = require "lapis.helper.view"

import generate_token from require "lapis.csrf"

class MyApp extends lapis.Application
  layout: require "views.my_view"

  @before_filter =>
    @csrf_token = generate_token @

    -- Load helpers that cache things to be rendered in the layout
    @ViewHelper = viewh!

  -- Routes
  "/": =>
    @page_title = "A javascript helper for lapis"
    render: "index"

```

__views/index.moon__: Use the `@ViewHelper` instantiated above to register some js/css for the page's layout.

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

    -- Provide some CSS for the layout
    @ViewHelper.css\head src: "/static/css/form_style.css" -- Places <script type="text/javascript" src="..." /> in layout head
    @ViewHelper.css\head ".panel h1 { color: black; }"     -- Places script block in layout head
    @ViewHelper.css\inline "#register-form { color: red; }"  -- Caches a style block, rendered at call to @ViewHelper.css\render_inline!

    -- Provide some javascript to be included in the layout (this example implements the jquery.validate library)
    @ViewHelper.js\add_form_validator "#register-form", {
      username:         { required: true, minlength: 2, maxlength: 25 }
      email:            { required: true, email: true }
      password:         { required: true, minlength: 8 }
      password_confirm: { required: true, equalTo: "input[name=password]"}
      agree_terms:      { required: true }
    }
```

__views/my_view.moon__: Render the cached javascript/css blocks in the layout.

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

        raw @ViewHelper.css\head!
  
      body ->
        -- Add caches css blocks
        raw @ViewHelper.css\inline!

        -- Insert page's contents from app route and/or the route's associated widget
        @content_for "inner"

        -- You should really put js libraries and linked scripts at the bottom to improve load times
        -- For example: I use js\head to store <script src=""... /> references, and js\footer to store things like custom jQuery code blocks
        raw @ViewHelper.js\head!

        -- Add cached script blocks
        -- For example: Store $(document).ready(...) here to run after jQuery is loaded
        raw @ViewHelper.js\footer!

```

## Status ##

I'm currently hacking this together to provide features I need whenever
I find that I need them. I would like this to become a less-hacky module
that can be used with ease and confidence along with lapis. Contributions
and/or requests are welcome.

