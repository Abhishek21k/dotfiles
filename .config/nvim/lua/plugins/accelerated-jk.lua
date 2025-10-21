return {
  "rainbowhxch/accelerated-jk.nvim",
  keys = {
    { "j", "<Plug>(accelerated_jk_gj)", mode = "n" },
    { "k", "<Plug>(accelerated_jk_gk)", mode = "n" },
    {
      "<leader>um",
      function()
        vim.g.accelerated_jk_enabled = not vim.g.accelerated_jk_enabled
        if vim.g.accelerated_jk_enabled then
          vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)", { silent = true })
          vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)", { silent = true })
          vim.notify("Accelerated j/k enabled", vim.log.levels.INFO)
        else
          vim.keymap.set("n", "j", "gj", { silent = true })
          vim.keymap.set("n", "k", "gk", { silent = true })
          vim.notify("Accelerated j/k disabled", vim.log.levels.INFO)
        end
      end,
      desc = "Toggle Motion Speed",
    },
  },
  opts = {
    mode = "time_driven",
    enable_deceleration = false,
    acceleration_motions = {},
    acceleration_limit = 80,
    acceleration_table = {
      3,
      5,
    },
  },
  init = function()
    -- Disable by default on startup
    vim.g.accelerated_jk_enabled = false
    vim.keymap.set("n", "j", "gj", { silent = true })
    vim.keymap.set("n", "k", "gk", { silent = true })
  end,
}
