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
          exclude = {
            ".git", ".DS_Store", ".trash",
            -- JS/TS
            "node_modules", "dist", ".next", "build",
            -- React Native / Expo
            ".expo", "android", "ios",
            -- Rust
            "target",
            -- Python
            "venv", ".venv", "env", "__pycache__", ".pytest_cache", ".tox", ".mypy_cache", ".ruff_cache",
            -- Go
            "vendor",
            -- Dart / Flutter
            ".dart_tool", ".pub-cache", ".pub",
          },
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
