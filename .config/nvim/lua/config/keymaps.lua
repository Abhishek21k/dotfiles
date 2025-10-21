-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim.keymap.set("n", "<leader>h", function()
--   Snacks.dashboard.open()
-- end, { desc = "Dashboard" })

vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backward" })

-- Insert mode: Delete to beginning of line (Command + Delete)
vim.keymap.set("i", "<D-BS>", "<C-u>", { desc = "Delete to line start" })
