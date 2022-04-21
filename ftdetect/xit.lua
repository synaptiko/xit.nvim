local augroup = vim.api.nvim_create_augroup('xit_filetype', { clear = true })
vim.api.nvim_create_autocmd('BufNewFile,BufRead', {
  group = augroup,
  pattern = '*.xit',
  command = 'set filetype=xit',
})
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'xit',
  command = 'setlocal shiftwidth=4 softtabstop=4 expandtab',
})
