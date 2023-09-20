local M = {}

function M.remove_cr(lines)
  for i, line in ipairs(lines) do
    if line:sub(-1, -1) == "\r" then -- To remove carriage return for windows
      lines[i] = line:sub(1, -2)
    end
  end
  return lines
end

function M.set_lines(buf_id, start, stop, lines)
  vim.bo[buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(buf_id, start, stop, false, lines)
  vim.bo[buf_id].modifiable = false
  vim.bo[buf_id].modified = false
end

return M
