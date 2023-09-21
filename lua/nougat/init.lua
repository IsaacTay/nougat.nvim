local config = require("nougat.config")
local utils = require("nougat.utils")

local M = {}

M.setup = config.setup
M.enabled = false

local NOUGAT_AUGROUP = vim.api.nvim_create_augroup("nougat", { clear = true })

function M.enable()
  if M.enabled then
    print("Cleared auto autocommands")
    vim.api.nvim_clear_autocmds({ group = NOUGAT_AUGROUP })
  end
  M.enabled = true
  if not (config.options.cli or config.options.api) then
    vim.notify("No cli or api specified:\nnougat disabled", "error", { title = "Nougat" })
    M.enabled = false
    return
  end
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = NOUGAT_AUGROUP,
    pattern = "*.pdf",
    callback = function()
      local buf_id = vim.api.nvim_get_current_buf();
      local file_path = vim.api.nvim_buf_get_name(buf_id)
      utils.set_lines(buf_id, 0, -1, { "PLACEHOLDER TEXT: Will be replaced once nougat completes", "Nougat log:" })
      local shell_fn
      if config.options.cli then
        shell_fn = vim.list_extend({ config.options.cli.cmd, file_path }, config.options.cli.additional_args)
      elseif config.options.api then
        shell_fn = { "curl", "-X", "POST", config.options.api.url .. "/predict/", "-H", "accept: application/json", "-H", "Content-Type: multipart/form-data", "-F", "file=@" .. file_path .. ";type=application/pdf" }
      end
      local output = false
      local first_line = 0
      vim.fn.jobstart(shell_fn, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          output = true
          if data then
            data = utils.format(data, config.options.api)
            utils.set_lines(buf_id, first_line, -1, data)
            first_line = -1
          end
        end,
        on_stderr = function(_, data)
          if data and not output then
            data = utils.format(data)
            utils.set_lines(buf_id, -1, -1, data)
          end
        end,
      })
    end
  })
  vim.notify("Nougat enabled", "info", { title = "Nougat" })
end

function M.disable()
  M.enabled = false
  vim.api.nvim_clear_autocmds({ group = NOUGAT_AUGROUP })
  vim.notify("Nougat disabled", "info", { title = "Nougat" })
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
