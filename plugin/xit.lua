-- TODO jiri: rework when 0.7 is officially out
if not vim.fn.has('nvim-0.6.0') then
  vim.cmd('echoerr "xit.nvim requires at least nvim-0.6.0."')
  return
end
-- if not vim.fn.has('nvim-0.7.0') then
--   vim.cmd('echoerr "xit.nvim requires at least nvim-0.6.0."')
--   return
-- end

local xit = require("xit")

-- TODO jiri: do we need this file at all if our plugin requires calling `setup` anyway?
if xit.is_configured() then
  -- TODO jiri: rework when 0.7 is officially out
  vim.cmd([[
    augroup xit_filetype
      autocmd!
      autocmd BufRead,BufNewFile,BufReadPost *.xit set filetype=xit
      autocmd FileType xit setlocal shiftwidth=4 softtabstop=4 expandtab
    augroup END
  ]])
  -- TODO jiri: rework when 0.7 is officially out
  -- local group = vim.api.nvim_create_augroup("xit_filetype", { clear = true })
  -- vim.api.nvim_create_autocmd("BufRead,BufNewFile,BufReadPost", {
  --   group = group,
  --   pattern = "*.xit",
  --   command = "set filetype=xit",
  -- })
  -- vim.api.nvim_create_autocmd('FileType', {
  --   group = group,
  --   pattern = "xit",
  --   command = "setlocal shiftwidth=4 softtabstop=4 expandtab",
  -- })

  vim.cmd([[
    highlight XitHeadline gui=underline,bold term=underline,bold

    highlight default link XitOpenCheckbox Property
    highlight default link XitOpenTaskMainLine Property
    highlight default link XitOpenTaskOtherLine Property
    highlight default link XitOpenTaskPriority TSDanger

    highlight default link XitCheckedCheckbox Comment
    highlight default link XitCheckedTaskMainLine Comment
    highlight default link XitCheckedTaskOtherLine Comment
    highlight default link XitCheckedTaskPriority Comment

    highlight default link XitOngoingCheckbox MoreMsg
    highlight default link XitOngoingTaskMainLine MoreMsg
    highlight default link XitOngoingTaskOtherLine MoreMsg
    highlight default link XitOngoingTaskPriority TSDanger

    " TODO how to make XitObsoleteTask to use both comment style & strikethrough?
    highlight default link XitObsoleteCheckbox Comment
    highlight default link XitObsoleteTaskMainLine Comment
    highlight default link XitObsoleteTaskOtherLine Comment
    highlight default link XitObsoleteTaskPriority Comment
    highlight XitObsoleteTaskMainLine gui=strikethrough term=strikethrough
    highlight XitObsoleteTaskOtherLine gui=strikethrough term=strikethrough
    highlight XitObsoleteTaskPriority gui=strikethrough term=strikethrough
  ]])
end
