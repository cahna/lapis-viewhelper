package = "lapis_viewhelper"
version = "dev-1"

source = {
  url = "git@github.com:cahna/lapis-viewhelper.git"
}

description = {
  summary = "Register JavaScript & CSS blocks at multiple locations within a Lapis request to be rendered in a page's layout.",
  maintainer = "Conor Heine <cheine@gmail.com>",
  license = "MIT",
}

dependencies = {
  "lua == 5.1",
  "lapis"
}

build = {
  type = "builtin",
  modules = {
    ["lapis.helper.view"] = "lapis/helper/view/init.lua",
  }
}
