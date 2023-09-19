local config = require("nougat.config")

local M = {}

M.setup = config.setup
M.enabled = false

local NOUGAT_AUGROUP = vim.api.nvim_create_augroup("nougat", { clear = true })

function M.enable()
  M.enabled = true
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = NOUGAT_AUGROUP,
    pattern = "*.pdf",
    callback = function()
      local buf_id = vim.api.nvim_get_current_buf();
      local file_path = vim.api.nvim_buf_get_name(buf_id)
      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { "PLACEHOLDER TEXT: Will be replaced once nougat completes", "Nougat log:" })
      local first_line = 0
      vim.bo[buf_id].modifiable = false
      vim.bo[buf_id].modified = false
      local shell_fn = { "nougat", "--markdown", file_path }
      print(vim.inspect(shell_fn))
      vim.fn.jobstart(shell_fn, {
        on_stdout = function(_, data)
          if data then
            table.remove(data)
            for i, line in ipairs(data) do
              if line:sub(-1, -1) == "\r" then -- To remove carriage return for windows
                data[i] = line:sub(1, -2)
              end
            end
            vim.bo[buf_id].modifiable = true
            vim.api.nvim_buf_set_lines(buf_id, first_line, -1, false, data)
            first_line = -1
            vim.bo[buf_id].modifiable = false
            vim.bo[buf_id].modified = false
          end
        end,
        on_stderr = function(_, data)
          if data then
            table.remove(data)
            for i, line in ipairs(data) do
              if line:sub(-1, -1) == "\r" then -- To remove carriage return for windows
                data[i] = line:sub(1, -2)
              end
            end
            vim.bo[buf_id].modifiable = true
            vim.api.nvim_buf_set_lines(buf_id, -1, -1, false, data)
            vim.bo[buf_id].modifiable = false
            vim.bo[buf_id].modified = false
          end
        end
      })
    end
  })
  print("Nougat enabled")
end

function M.disable()
  M.enabled = false
  vim.api.nvim_clear_autocmds({ group = NOUGAT_AUGROUP })
  print("Nougat disabled")
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
