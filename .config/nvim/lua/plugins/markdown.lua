return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local mdl = require("lint").linters["markdownlint-cli2"]
      if mdl then
        mdl.args = { "--config", vim.fn.expand("~/.markdownlint-cli2.jsonc") }
      end
    end,
  },
}
