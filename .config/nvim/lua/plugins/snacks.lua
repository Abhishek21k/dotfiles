return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = {
        position = "float",
      },
    },
    animate = { enabled = false },
    scroll = { enabled = false },
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".git", ".DS_Store", "node_modules", "dist", ".next", ".expo", "build", "target" },
        },
        grep = {
          hidden = false,
          ignored = false,
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
