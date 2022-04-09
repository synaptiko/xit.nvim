if !has('nvim-0.7.0')
  echoerr "xit.nvim requires at least nvim-0.7.0."
  finish
end

let s:xit = luaeval('require("xit")')

if s:xit.is_configured()
  " TODO figure out if we need to do anything here
  " FIXME
  " command! MyPluginGreet call s:my_plugin.greet()
endif

highlight XitHeadline gui=underline,bold term=underline,bold

highlight default link XitOpenCheckbox Property
highlight default link XitOpenTaskMainLine Property
highlight default link XitOpenTaskOtherLine Property
highlight default link XitOpenTaskPriority TextDanger

highlight default link XitCheckedCheckbox Comment
highlight default link XitCheckedTaskMainLine Comment
highlight default link XitCheckedTaskOtherLine Comment
highlight default link XitCheckedTaskPriority Comment

highlight default link XitOngoingCheckbox MoreMsg
highlight default link XitOngoingTaskMainLine MoreMsg
highlight default link XitOngoingTaskOtherLine MoreMsg
highlight default link XitOngoingTaskPriority TextDanger

" TODO how to make XitObsoleteTask to use both comment style & strikethrough?
highlight default link XitObsoleteCheckbox Comment
highlight default link XitObsoleteTaskMainLine Comment
highlight default link XitObsoleteTaskOtherLine Comment
highlight default link XitObsoleteTaskPriority Comment
highlight XitObsoleteTaskMainLine gui=strikethrough term=strikethrough
highlight XitObsoleteTaskOtherLine gui=strikethrough term=strikethrough
highlight XitObsoleteTaskPriority gui=strikethrough term=strikethrough
