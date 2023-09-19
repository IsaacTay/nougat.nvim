local M = {}


local defaults = {
}

M.options = defaults

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  require("nougat").enable()
end

return M
