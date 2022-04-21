augroup xit_filetype
  autocmd!
  autocmd BufNewFile,BufRead *.xit set filetype=xit
  autocmd FileType xit setlocal shiftwidth=4 softtabstop=4 expandtab
augroup END
