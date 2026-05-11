return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = { "Amansingh-afk/milli.nvim" },
  opts = function(_, opts)
    local splash = require("milli").load({ splash = "fire" })

    opts.dashboard = {
      enabled = true,
      sections = {
        { section = "header", text = table.concat(splash.frames[1], "\n") },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    }

    opts.terminal = {
      win = { position = "float" },
    }
    opts.animate = { enabled = false }
    opts.scroll = { enabled = false }
    opts.picker = {
      matcher = { frecency = true },
      sources = {
        files = {
          dirs = { vim.uv.cwd() },
          hidden = true,
          ignored = true,
          exclude = {
            ".git", ".DS_Store", ".trash",
            "node_modules", "dist", ".next", "build",
            ".expo", "android", "ios",
            "target",
            "venv", ".venv", "env", "__pycache__", ".pytest_cache", ".tox", ".mypy_cache", ".ruff_cache",
            "vendor",
            ".dart_tool", ".pub-cache", ".pub",
          },
        },
        grep = {
          dirs = { vim.uv.cwd() },
          hidden = false,
          ignored = false,
          exclude = {
            ".git", ".DS_Store",
            "node_modules", "dist", ".next", "build",
            "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb",
            ".expo", "android", "ios",
            "target", "Cargo.lock",
            "venv", ".venv", "env", "__pycache__", ".pytest_cache", ".tox", ".mypy_cache", ".ruff_cache",
            "vendor", "go.sum",
            ".dart_tool", ".pub-cache", ".pub",
          },
        },
        explorer = { hidden = true, ignored = true },
      },
    }

    return opts
  end,
  config = function(_, opts)
    require("snacks").setup(opts)
    require("milli").snacks({ splash = "fire", loop = true })
  end,
}
