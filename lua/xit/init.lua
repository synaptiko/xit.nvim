local ts_utils = require('nvim-treesitter.ts_utils')

local set_highlighting = function()
  vim.api.nvim_set_hl(0, 'XitHeadline', { underline = true, bold = true, link = 'Normal' })

  vim.api.nvim_set_hl(0, 'XitOpenCheckbox', { bold = true, link = 'Normal' })
  vim.api.nvim_set_hl(0, 'XitOpenTaskMainLine', { bold = false, link = 'Normal' })
  vim.api.nvim_set_hl(0, 'XitOpenTaskOtherLine', { bold = false, link = 'Normal' })
  vim.api.nvim_set_hl(0, 'XitOpenTaskPriority', { bold = true, link = 'ErrorMsg' })

  vim.api.nvim_set_hl(0, 'XitOngoingCheckbox', { bold = true, link = 'MoreMsg' })
  vim.api.nvim_set_hl(0, 'XitOngoingTaskMainLine', { bold = true, link = 'MoreMsg' })
  vim.api.nvim_set_hl(0, 'XitOngoingTaskOtherLine', { bold = true, link = 'MoreMsg' })
  vim.api.nvim_set_hl(0, 'XitOngoingTaskPriority', { bold = true, link = 'ErrorMsg' })

  vim.api.nvim_set_hl(0, 'XitCheckedCheckbox', { bold = false, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitCheckedTaskMainLine', { bold = false, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitCheckedTaskOtherLine', { bold = false, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitCheckedTaskPriority', { bold = false, italic = false, link = 'Comment' })

  vim.api.nvim_set_hl(0, 'XitObsoleteCheckbox', { strikethrough = true, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskMainLine', { strikethrough = true, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskOtherLine', { strikethrough = true, italic = false, link = 'Comment' })
  vim.api.nvim_set_hl(0, 'XitObsoleteTaskPriority', { strikethrough = true, italic = false, link = 'Comment' })
end

local set_mappings = function(M, augroup, options)
  local jump_between_all_tasks = { 'task' }
  local jump_between_open_and_ongoing_tasks = { 'open_task', 'ongoing_task' }
  local jump_between = options.default_jump_group == 'all' and jump_between_all_tasks
    or jump_between_open_and_ongoing_tasks

  local toggle_jumps = function()
    if jump_between == jump_between_all_tasks then
      jump_between = jump_between_open_and_ongoing_tasks
      print('Jumping toggled to open and ongoing tasks')
    else
      jump_between = jump_between_all_tasks
      print('Jumping toggled to all tasks')
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'xit',
    callback = function()
      vim.keymap.set('n', '<C-n>', function()
        M.jump_to_next_task(options.wrap_jumps, jump_between)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<C-p>', function()
        M.jump_to_previous_task(options.wrap_jumps, jump_between)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<C-S-n>', function()
        M.jump_to_next_headline(options.wrap_jumps)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<C-S-p>', function()
        M.jump_to_previous_headline(options.wrap_jumps)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<C-t>', function()
        M.toggle_checkbox(false)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<C-S-t>', function()
        M.toggle_checkbox(true)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>n', function()
        M.create_new_task(false)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>N', function()
        M.create_new_task(true)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>m', function()
        M.create_new_headline(false)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>M', function()
        M.create_new_headline(true)
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>t', toggle_jumps, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>x', M.delete_task, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>fo', function()
        M.filter_tasks({ 'open_task', 'ongoing_task' })
      end, { buffer = true, silent = true })
      vim.keymap.set('n', '<leader>fc', function()
        M.filter_tasks({ 'checked_task' })
      end, { buffer = true, silent = true })
      vim.keymap.set('i', '<CR>', M.create_new_task_in_insert_mode, { buffer = true, silent = true })
      vim.keymap.set('i', '<S-CR>', M.create_indented_line_in_insert_mode, { buffer = true, silent = true })
    end,
  })
end

local get_node_for_cursor = function(cursor)
  if cursor == nil then
    cursor = vim.api.nvim_win_get_cursor(0)
  end
  local root = ts_utils.get_root_for_position(unpack({ cursor[1] - 1, cursor[2] }))
  if not root then
    return
  end
  return root:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
end

local get_node_of_type = function(type, cursor)
  local node = get_node_for_cursor(cursor)

  if node == nil then
    return nil
  end

  local root = ts_utils.get_root_for_node(node)

  while node ~= nil and node ~= root and node:type() ~= type do
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
  elseif
    task_node:type() == 'open_task'
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
  if checkbox_node:type() == 'open_checkbox' then
    return toogle_back and '~' or '@'
  elseif checkbox_node:type() == 'ongoing_checkbox' then
    return toogle_back and ' ' or 'x'
  elseif checkbox_node:type() == 'checked_checkbox' then
    return toogle_back and '@' or '~'
  else
    return toogle_back and 'x' or ' '
  end
end

local find_next_task = function(current_task_node, start_line, end_line, types)
  types = types or { 'task' }

  for i = start_line, end_line do
    local next_task = get_node_of_types(types, { i, 0 })

    if
      next_task ~= nil
      and (current_task_node == nil or (next_task ~= current_task_node and next_task:parent() ~= current_task_node))
    then
      local checkbox_row = get_checkbox(next_task):range()
      vim.api.nvim_win_set_cursor(0, { checkbox_row + 1, 4 })
      return true
    end
  end

  return false
end

local find_previous_task = function(current_task_node, start_line, end_line, types)
  types = types or { 'task' }

  for i = start_line, end_line, -1 do
    local previous_task = get_node_of_types(types, { i, 0 })

    if
      previous_task ~= nil
      and (
        current_task_node == nil
        or (previous_task ~= current_task_node and previous_task:parent() ~= current_task_node)
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
    local next_headline = get_node_of_type('headline', { i, 0 })

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
    local previous_headline = get_node_of_type('headline', { i, 0 })

    if previous_headline ~= nil and (current_headline_node == nil or previous_headline ~= current_headline_node) then
      local headline_row = previous_headline:range()
      vim.api.nvim_win_set_cursor(0, { headline_row + 1, 0 })
      return true
    end
  end

  return false
end

local insert_new_line = function()
  local key = vim.api.nvim_replace_termcodes('<CR>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end

local insert_new_indented_line = function()
  local key = vim.api.nvim_replace_termcodes('<CR><Tab>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end

-----------------------
-- MODULE DEFINITION --
-----------------------
local options = {
  disable_default_highlights = false,
  disable_default_mappings = false,
  default_jump_group = 'all', -- possible values: all, open_and_ongoing
  wrap_jumps = true,
}
local configured = false
local M = {}

M.setup = function(opts)
  opts = opts or {}
  options = vim.tbl_deep_extend('force', options, opts)
  configured = true

  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  parser_config.xit = {
    install_info = {
      url = 'https://github.com/synaptiko/tree-sitter-xit',
      files = { 'src/parser.c' },
      revision = '0.1',
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = 'xit',
  }

  local augroup = vim.api.nvim_create_augroup('xit_highlights_mappings', { clear = true })
  if not options.disable_default_highlights then
    set_highlighting()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = augroup,
      callback = set_highlighting,
    })
  end

  if not options.disable_default_mappings then
    set_mappings(M, augroup, options)
  end
end

M.toggle_checkbox = function(toggle_back)
  local task_node = get_node_of_type('task')

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
  local current_task_node = get_node_of_type('task')
  local cursor = vim.api.nvim_win_get_cursor(0)
  local max_line = vim.api.nvim_buf_line_count(0)
  local found = find_next_task(current_task_node, cursor[1], max_line, types)

  if wrap and not found then
    find_next_task(current_task_node, 0, cursor[1] - 1, types)
  end
end

M.jump_to_previous_task = function(wrap, types)
  local current_task_node = get_node_of_type('task')
  local cursor = vim.api.nvim_win_get_cursor(0)
  local found = find_previous_task(current_task_node, cursor[1], 0, types)

  if wrap and not found then
    local max_line = vim.api.nvim_buf_line_count(0)

    find_previous_task(current_task_node, max_line, cursor[1] + 1, types)
  end
end

M.jump_to_next_headline = function(wrap)
  local current_headline_node = get_node_of_type('headline')
  local cursor = vim.api.nvim_win_get_cursor(0)
  local max_line = vim.api.nvim_buf_line_count(0)
  local found = find_next_headline(current_headline_node, cursor[1], max_line)

  if wrap and not found then
    find_next_headline(current_headline_node, 0, cursor[1] - 1)
  end
end

M.jump_to_previous_headline = function(wrap)
  local current_headline_node = get_node_of_type('headline')
  local cursor = vim.api.nvim_win_get_cursor(0)
  local found = find_previous_headline(current_headline_node, cursor[1], 0)

  if wrap and not found then
    local max_line = vim.api.nvim_buf_line_count(0)

    find_previous_headline(current_headline_node, max_line, cursor[1] + 1)
  end
end

M.create_new_task = function(before_current_task, stay_in_current_mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_task_node = get_node_of_type('task')
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

  vim.api.nvim_buf_set_lines(0, insertion_row, insertion_row, false, { '[ ] ' })
  vim.api.nvim_win_set_cursor(0, { insertion_row + 1, 4 })
  if not stay_in_current_mode then
    vim.cmd('startinsert!')
  end
end

M.create_new_headline = function(before_current_task, stay_in_current_mode)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_task_node = get_node_of_type('task')
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

  vim.api.nvim_buf_set_lines(0, insertion_row, insertion_row, false, { '', '' })
  vim.api.nvim_win_set_cursor(0, { insertion_row + 2, 0 })
  if not stay_in_current_mode then
    vim.cmd('startinsert!')
  end
end

M.create_new_task_in_insert_mode = function()
  local current_column = vim.api.nvim_eval('col(".")')
  local last_column = vim.api.nvim_eval('col("$")')

  if current_column == 1 then
    insert_new_line()
  elseif current_column == last_column then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_node = get_node_of_type('headline') or get_node_of_type('task', { cursor[1], cursor[2] - 1 })
    local at_the_end_of_task = false

    if current_node and current_node:type() == 'task' then
      local _, _, end_row = current_node:range()
      at_the_end_of_task = end_row + 1 == cursor[1]
    end

    if
      current_node and ((current_node:type() == 'task' and at_the_end_of_task) or current_node:type() == 'headline')
    then
      M.create_new_task(false, true)
    else
      local other_line_node = get_node_of_type('other_line', { cursor[1], cursor[2] - 1 })

      if other_line_node == nil then
        insert_new_indented_line()
      else
        insert_new_line()
      end
    end
  else
    local current_node = get_node_of_type('task')
    local other_line_node = get_node_of_type('other_line')
    local indent_node = get_node_of_type('indent')

    if current_node and current_node:type() == 'task' and (other_line_node == nil or indent_node) then
      insert_new_indented_line()
    else
      insert_new_line()
    end
  end
end

M.create_indented_line_in_insert_mode = function()
  local current_column = vim.api.nvim_eval('col(".")')
  local last_column = vim.api.nvim_eval('col("$")')

  if current_column == last_column then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local insertion_row = cursor[1]

    vim.api.nvim_buf_set_lines(0, insertion_row, insertion_row, false, { '    ' })
    vim.api.nvim_win_set_cursor(0, { insertion_row + 1, 4 })
  else
    local current_node = get_node_of_type('task')
    local other_line_node = get_node_of_type('other_line')

    if current_node and current_node:type() == 'task' and other_line_node == nil then
      insert_new_indented_line()
    else
      insert_new_line()
    end
  end
end

M.delete_task = function()
  local current_task_node = get_node_of_type('task')

  if current_task_node ~= nil then
    local start_row, _, end_row = current_task_node:range()
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
  else
    print('No task found under the cursor')
  end
end

M.filter_tasks = function(types)
  local root = ts_utils.get_root_for_node(get_node_for_cursor())
  local tasks_to_remove = {}

  if types == nil then
    types = { 'open_task', 'ongoing_task' }
  end

  -- 1. eliminate tasks
  for node in root:iter_children() do
    if node:type() == 'task' then
      local task_type = node:child():type()
      local match = false

      for _, type in ipairs(types) do
        if task_type == type then
          match = true
          break
        end
      end

      if not match then
        table.insert(tasks_to_remove, node)
      end
    end
  end

  for i = #tasks_to_remove, 1, -1 do
    local start_row, _, end_row = tasks_to_remove[i]:range()
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
  end

  -- 2. eliminate empty headlines (headlines which are not followed by any tasks)
  local max_line = vim.api.nvim_buf_line_count(0)
  local was_empty_line_or_headline_or_eof = true -- it's EOF initially

  for i = max_line, 1, -1 do
    local node = get_node_for_cursor({ i, 0 })

    if node:type() == 'headline' and was_empty_line_or_headline_or_eof then
      vim.api.nvim_buf_set_lines(0, i - 1, i + 1, false, {})
      was_empty_line_or_headline_or_eof = true
    elseif node == root then
      was_empty_line_or_headline_or_eof = true
    else
      was_empty_line_or_headline_or_eof = false
    end
  end

  -- 3. eliminate multiple empty lines, only keep 1
  max_line = vim.api.nvim_buf_line_count(0)
  local empty_line_count = 0
  local was_eof = true -- it's EOF initially

  for i = max_line, 1, -1 do
    local node = get_node_for_cursor({ i, 0 })

    print(i, empty_line_count)
    if node == root then
      empty_line_count = empty_line_count + 1 + (was_eof and 1 or 0)
    elseif empty_line_count >= 2 then
      print('deleted', i, i + empty_line_count - 1)
      vim.api.nvim_buf_set_lines(0, i, i + empty_line_count - 1, false, {})
      empty_line_count = 0
    else
      empty_line_count = 0
    end

    was_eof = false
  end
end

M.is_configured = function()
  return configured
end

return M
