return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = false,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        toml = { "taplo" },
      },
    },
  },
}
