local M = {}

function M.get_selected_code()
  -- Get the current visual selection or current line if no selection
  local mode = vim.fn.mode()
  local start_pos, end_pos

  if mode == 'v' or mode == 'V' or mode == '' then
    -- Visual mode - get selection
    start_pos = vim.fn.getpos "'<"
    end_pos = vim.fn.getpos "'>"
  else
    -- Normal mode - get current function or line
    local cursor_pos = vim.fn.getpos '.'
    start_pos = cursor_pos
    end_pos = cursor_pos
  end

  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Get the lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    return ''
  end

  -- If we have a visual selection, handle partial line selection
  if mode == 'v' or mode == '' then
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    if #lines == 1 then
      -- Single line selection
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      -- Multi-line selection
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  end

  return table.concat(lines, '\n')
end

function M.get_current_function()
  -- Try to get the current function using treesitter
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local current_node = ts_utils.get_node_at_cursor()

  if not current_node then
    return M.get_selected_code()
  end

  -- Walk up the tree to find a function node
  while current_node do
    local node_type = current_node:type()
    if node_type:match 'function' or node_type:match 'method' then
      local start_row, start_col, end_row, end_col = current_node:range()
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

      -- Handle partial first and last lines
      if #lines > 0 then
        if start_col > 0 then
          lines[1] = string.sub(lines[1], start_col + 1)
        end
        if end_col < string.len(lines[#lines]) then
          lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
      end

      return table.concat(lines, '\n')
    end
    current_node = current_node:parent()
  end

  -- Fallback to selected code
  return M.get_selected_code()
end

function M.validate_code_selection(code)
  -- Basic validation to ensure we have meaningful code
  if not code or code:match '^%s*$' then
    return false, 'No code selected'
  end

  if string.len(code) < 10 then
    return false, 'Selected code too short for meaningful analysis'
  end

  return true, 'Valid code selection'
end

return M
