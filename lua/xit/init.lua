local ts_utils = require("nvim-treesitter.ts_utils")

local set_highlighting = function()
  local headlineHighlight = { underline = true, bold = true }
  local openHighlight = {}
  local openCheckboxHighlight = { bold = true }
  local ongoingHighlight = vim.api.nvim_get_hl_by_name('MoreMsg', true)
  local checkedHighlight = vim.api.nvim_get_hl_by_name('Comment', true)
  local obsoleteHighlight = vim.api.nvim_get_hl_by_name('Comment', true)
  local obsoleteStrikedHighlight = vim.api.nvim_get_hl_by_name('Comment', true)
  local priorityHighlight = vim.api.nvim_get_hl_by_name('TSDanger', true)

  priorityHighlight.bold = true
  checkedHighlight.italic = nil
  obsoleteHighlight.italic = nil
  obsoleteStrikedHighlight.italic = nil
  obsoleteStrikedHighlight.strikethrough = true

  vim.api.nvim_set_hl(0, 'XitHeadline', headlineHighlight)

  vim.api.nvim_set_hl(0, 'XitOpenCheckbox', openCheckboxHighlight)
  vim.api.nvim_set_hl(0, 'XitOpenTaskMainLine', openHighlight)
  vim.api.nvim_set_hl(0, 'XitOpenTaskOtherLine', openHighlight)
  vim.api.nvim_set_hl(0, 'XitOpenTaskPriority', priorityHighlight)

  vim.api.nvim_set_hl(0, 'XitOngoingCheckbox', ongoingHighlight)
  vim.api.nvim_set_hl(0, 'XitOngoingTaskMainLine', ongoingHighlight)
  vim.api.nvim_set_hl(0, 'XitOngoingTaskOtherLine', ongoingHighlight)
  vim.api.nvim_set_hl(0, 'XitOngoingTaskPriority', priorityHighlight)

  vim.api.nvim_set_hl(0, 'XitCheckedCheckbox', checkedHighlight)
  vim.api.nvim_set_hl(0, 'XitCheckedTaskMainLine', checkedHighlight)
  vim.api.nvim_set_hl(0, 'XitCheckedTaskOtherLine', checkedHighlight)
  vim.api.nvim_set_hl(0, 'XitCheckedTaskPriority', checkedHighlight)

  vim.api.nvim_set_hl(0, 'XitObsoleteCheckbox', obsoleteHighlight)
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskMainLine', obsoleteStrikedHighlight)
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskOtherLine', obsoleteStrikedHighlight)
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskPriority', obsoleteStrikedHighlight)
end

local get_node_for_cursor = function(cursor)
  if cursor == nil then
    cursor = vim.api.nvim_win_get_cursor(0)
  end
  local root = ts_utils.get_root_for_position(unpack({ cursor[1] - 1, cursor[2] }))
  if not root then return end
  return root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
end

local get_node_of_type = function(type, cursor)
  local node = get_node_for_cursor(cursor)

  if node == nil then
    return nil
  end

  local root = ts_utils.get_root_for_node(node)

  while (node ~= nil and node ~= root and node:type() ~= type) do
    node = node:parent()
  end

  if node:type() == type then
    return node
  else
    return nil
  end
end

local get_node_of_types = function(types, cursor)
  for _, type in ipairs(types) do
    local node = get_node_of_type(type, cursor)
    if node ~= nil then
      return node
    end
  end
end

local get_checkbox = function(task_node)
  if task_node:type() == 'task' then
    return task_node:child():child()
  elseif task_node:type() == 'open_task'
    or task_node:type() == 'ongoing_task'
    or task_node:type() == 'checked_task'
    or task_node:type() == 'obsolete_task'
  then
    return task_node:child()
  else
    return nil
  end
end

local get_next_checkbox_status_char = function(checkbox_node, toogle_back)
  if checkbox_node:type() == "open_checkbox" then
    return toogle_back and '~' or '@'
  elseif checkbox_node:type() == "ongoing_checkbox" then
    return toogle_back and ' ' or 'x'
  elseif checkbox_node:type() == "checked_checkbox" then
    return toogle_back and '@' or '~'
  else
    return toogle_back and 'x' or ' '
  end
end

local find_next_task = function(current_task_node, start_line, end_line, types)
  types = types or { "task" }

  for i = start_line, end_line do
    local next_task = get_node_of_types(types, { i, 0 })

    if next_task ~= nil
      and (current_task_node == nil
        or (next_task ~= current_task_node
          and next_task:parent() ~= current_task_node
        )
      )
    then
      local checkbox_row = get_checkbox(next_task):range()
      vim.api.nvim_win_set_cursor(0, { checkbox_row + 1, 4 })
      return true
    end
  end

  return false
end

local find_previous_task = function(current_task_node, start_line, end_line, types)
  types = types or { "task" }

  for i = start_line, end_line, -1 do
    local previous_task = get_node_of_types(types, { i, 0 })

    if previous_task ~= nil
      and (current_task_node == nil
        or (previous_task ~= current_task_node
          and previous_task:parent() ~= current_task_node
        )
      )
    then
      local checkbox_row = get_checkbox(previous_task):range()
      vim.api.nvim_win_set_cursor(0, { checkbox_row + 1, 4 })
      return true
    end
  end

  return false
end

local find_next_headline = function(current_headline_node, start_line, end_line)
  for i = start_line, end_line do
    local next_headline = get_node_of_type("headline", { i, 0 })

    if next_headline ~= nil and (current_headline_node == nil or next_headline ~= current_headline_node) then
      local headline_row = next_headline:range()
      vim.api.nvim_win_set_cursor(0, { headline_row + 1, 0 })
      return true
    end
  end

  return false
end

local find_previous_headline = function(current_headline_node, start_line, end_line)
  for i = start_line, end_line, -1 do
    local previous_headline = get_node_of_type("headline", { i, 0 })

    if previous_headline ~= nil and (current_headline_node == nil or previous_headline ~= current_headline_node) then
      local headline_row = previous_headline:range()
      vim.api.nvim_win_set_cursor(0, { headline_row + 1, 0 })
      return true
    end
  end

  return false
end

-----------------------
-- MODULE DEFINITION --
-----------------------
local options = {
  in_development = false
}
local configured = false
local M = {}

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

  local group = vim.api.nvim_create_augroup("xit_filetype", { clear = true })
  vim.api.nvim_create_autocmd("BufRead,BufNewFile,BufReadPost", {
    group = group,
    pattern = "*.xit",
    command = "set filetype=xit",
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = "xit",
    command = "setlocal shiftwidth=4 softtabstop=4 expandtab",
  })

  set_highlighting()

  if options.in_development then
    vim.cmd([[
      nnoremap <silent> <leader>x <cmd>lua package.loaded['xit'] = nil<CR><cmd>lua xit = require'xit'<CR>
    ]])
  end
end

M.toggle_checkbox = function(toggle_back)
  local task_node = get_node_of_type("task")

  if task_node == nil then
    return
  end

  local checkbox_node = get_checkbox(task_node)
  local next_status = get_next_checkbox_status_char(checkbox_node, toggle_back)
  local bufnr = vim.api.nvim_get_current_buf()
  local start_row, start_col, end_row, end_col = checkbox_node:range()

  vim.api.nvim_buf_set_text(bufnr, start_row, start_col + 1, end_row, end_col - 1, { next_status })
end

M.jump_to_next_task = function(wrap, types)
  local current_task_node = get_node_of_type("task")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local max_line = vim.api.nvim_buf_line_count(0)
  local found = find_next_task(current_task_node, cursor[1], max_line, types)

  if wrap and not found then
    find_next_task(current_task_node, 0, cursor[1] - 1, types)
  end
end

M.jump_to_previous_task = function(wrap, types)
  local current_task_node = get_node_of_type("task")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local found = find_previous_task(current_task_node, cursor[1], 0, types)

  if wrap and not found then
    local max_line = vim.api.nvim_buf_line_count(0)

    find_previous_task(current_task_node, max_line, cursor[1] + 1, types)
  end
end

M.jump_to_next_headline = function(wrap)
  local current_headline_node = get_node_of_type("headline")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local max_line = vim.api.nvim_buf_line_count(0)
  local found = find_next_headline(current_headline_node, cursor[1], max_line)

  if wrap and not found then
    find_next_headline(current_headline_node, 0, cursor[1] - 1)
  end
end

M.jump_to_previous_headline = function(wrap)
  local current_headline_node = get_node_of_type("headline")
  local cursor = vim.api.nvim_win_get_cursor(0)
  local found = find_previous_headline(current_headline_node, cursor[1], 0)

  if wrap and not found then
    local max_line = vim.api.nvim_buf_line_count(0)

    find_previous_headline(current_headline_node, max_line, cursor[1] + 1)
  end
end

M.create_new_task = function(before_current_task, stay_in_current_mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_task_node = get_node_of_type("task")
  local insertion_row

  if current_task_node ~= nil then
    local start_row, _, end_row = current_task_node:range()

    if before_current_task then
      insertion_row = start_row
    else
      insertion_row = end_row + 1
    end
  else
    insertion_row = cursor[1] - (before_current_task and 1 or 0)
  end

  vim.api.nvim_buf_set_lines(0, insertion_row, insertion_row, false, { "[ ] " })
  vim.api.nvim_win_set_cursor(0, { insertion_row + 1, 4 })
  if not stay_in_current_mode then
    vim.cmd('startinsert!')
  end
end

M.create_new_heading = function(before_current_task, stay_in_current_mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_task_node = get_node_of_type("task")
  local insertion_row

  if current_task_node ~= nil then
    local start_row, _, end_row = current_task_node:range()

    if before_current_task then
      insertion_row = start_row
    else
      insertion_row = end_row + 1
    end
  else
    insertion_row = cursor[1] - (before_current_task and 1 or 0)
  end

  vim.api.nvim_buf_set_lines(0, insertion_row, insertion_row, false, { "", "" })
  vim.api.nvim_win_set_cursor(0, { insertion_row + 2, 0 })
  if not stay_in_current_mode then
    vim.cmd('startinsert!')
  end
end

M.is_configured = function()
   return configured
end

return M
