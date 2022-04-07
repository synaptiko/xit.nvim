if !has('nvim-0.7.0')
  echoerr "xit.nvim requires at least nvim-0.7.0."
  finish
end

let s:xit = luaeval('require("xit")')

if s:xit.is_configured()
	" TODO figure out if we need to do anything here
  " command! MyPluginGreet call s:my_plugin.greet()
endif

highlight default link XitOpenCheckbox Property
highlight default link XitOngoingTask MoreMsg
highlight default link XitCheckedTask Comment
highlight default link XitObsoleteTask Comment
highlight XitObsoleteTask gui=strikethrough term=strikethrough
highlight default link XitOpenTaskName Property
