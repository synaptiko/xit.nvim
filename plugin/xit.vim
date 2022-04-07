if exists('g:loaded_xit')
  finish
endif
let g:loaded_xit = 1

let s:xit = luaeval('require("xit")')

augroup xit_filetype
	autocmd!
	autocmd BufRead,BufNewFile,BufReadPost *.xit set filetype=xit
	autocmd FileType xit setlocal shiftwidth=4 softtabstop=4 expandtab
augroup END
