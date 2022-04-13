local ts_utils = require("nvim-treesitter.ts_utils")

local options = {
  in_development = false
}
local configured = false
local M = {}

local get_node_for_cursor = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local root = ts_utils.get_root_for_position(unpack({ cursor[1] - 1, cursor[2] }))
  if not root then return end
  return root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
end

M.setup = function(opts)
  options = vim.tbl_deep_extend('force', options, opts)
  configured = true

  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.xit = {
    install_info = {
      url = "https://github.com/synaptiko/tree-sitter-xit",
      files = { "src/parser.c" },
      branch = "master",
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "xit",
  }

  if options.in_development then
    vim.cmd([[
      nnoremap <silent> <leader>x <cmd>lua package.loaded['xit'] = nil<CR><cmd>lua xit = require'xit'<CR>
    ]])
  end
end

local get_task_node = function()
  local node = get_node_for_cursor()

  if node == nil then
    return nil
  end

  local root = ts_utils.get_root_for_node(node)

  while (node ~= nil and node ~= root and node:type() ~= "task") do
    node = node:parent()
  end

  if node:type() == "task" then
    return node
  else
    return nil
  end
end

local get_checkbox = function(task_node)
  return task_node:child():child()
end

local get_next_checkbox_status_char = function(checkbox_node)
  if checkbox_node:type() == "open_checkbox" then
    return '@'
  elseif checkbox_node:type() == "ongoing_checkbox" then
    return 'x'
  elseif checkbox_node:type() == "checked_checkbox" then
    return '~'
  else
    return ' '
  end
end

M.toggle_checkbox = function()
  local task_node = get_task_node()

  if task_node == nil then
    return
  end

  local checkbox_node = get_checkbox(task_node)
  local next_status = get_next_checkbox_status_char(checkbox_node)
  local bufnr = vim.api.nvim_get_current_buf()
  local start_row, start_col, end_row, end_col = checkbox_node:range()

  vim.api.nvim_buf_set_text(bufnr, start_row, start_col + 1, end_row, end_col - 1, { next_status })
end

M.is_configured = function()
   return configured
end

return M
