return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    opts = {},
    keys = {
      {
        "]h",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "Next hunk",
      },
      {
        "[h",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "Previous hunk",
      },
      { "<leader>gp",  "<cmd>Gitsigns preview_hunk<CR>",              desc = "Preview hunk" },
      { "<leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle current line blame" },
      { "<leader>gtd", "<cmd>Gitsigns toggle_deleted<CR>",            desc = "Toggle deleted" },
      { "<leader>gb",  "<cmd>Gitsigns blame<CR>",                     desc = "Gitsigns blames" },
    },
  },
  {
    "folke/todo-comments.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufEnter" },
    cmd = { "TodoTrouble", "TodoFzfLua" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },
      { "<leader>xt", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>",                                                desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble toggle<CR>",                                                                 desc = "Todo (Trouble)" },
      { "<leader>ft", function() require('fzf-lua').grep({ search = 'TODO|HACK|PERF|NOTE|FIX', no_esc = true }) end, desc = "Search TODO, HACK, PERF, NOTE, FIX (fzf-lua)" }
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "BufReadPre",
    config = function()
      require("nvim-surround").setup({
      })
    end
  },
  -- {
  --   'echasnovski/mini.surround',
  --   version = '*',
  --   config = function()
  --     require("mini.surround").setup({})
  --   end
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- Load at startup
    priority = 1000, -- Load before other plugins
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
    },
    main = "ibl",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
}
