if !has('nvim-0.7.0')
  echoerr "xit.nvim requires at least nvim-0.7.0."
  finish
end

let s:xit = luaeval('require("xit")')

if s:xit.is_configured()
	" TODO figure out if we need to do anything here
  " command! MyPluginGreet call s:my_plugin.greet()
endif
