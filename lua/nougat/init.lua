local config = require("nougat.config")
local utils = require("nougat.utils")

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
      utils.set_lines(buf_id, 0, -1, { "PLACEHOLDER TEXT: Will be replaced once nougat completes", "Nougat log:" })
      local first_line = 0
      local shell_fn = vim.list_extend({ config.options.cli.cmd, file_path }, config.options.cli.additional_args)
      vim.fn.jobstart(shell_fn, {
        on_stdout = function(_, data)
          if data then
            table.remove(data)
            utils.remove_cr(data)
            utils.set_lines(buf_id, first_line, -1, data)
            first_line = -1
          end
        end,
        on_stderr = function(_, data)
          if data then
            table.remove(data)
            utils.remove_cr(data)
            utils.set_lines(buf_id, -1, -1, data)
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
