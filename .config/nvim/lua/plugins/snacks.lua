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
      matcher = {
        frecency = true,
      },
      sources = {
        files = {
          dirs = { vim.uv.cwd() },
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
          dirs = { vim.uv.cwd() },
          hidden = false,
          ignored = false,
          exclude = {
            ".git", ".DS_Store",
            -- JS/TS
            "node_modules", "dist", ".next", "build",
            "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb",
            -- React Native / Expo
            ".expo", "android", "ios",
            -- Rust
            "target", "Cargo.lock",
            -- Python
            "venv", ".venv", "env", "__pycache__", ".pytest_cache", ".tox", ".mypy_cache", ".ruff_cache",
            -- Go
            "vendor", "go.sum",
            -- Dart / Flutter
            ".dart_tool", ".pub-cache", ".pub",
          },
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
