return {
  {
    "saghen/blink.cmp",
    version = "v0.*",
    dependencies = 'rafamadriz/friendly-snippets',
    event = "InsertEnter",
    opts = {
      appearance = {
        nerd_font_variant = "mono",
      },
      keymap = {
        preset = "enter",
        ["<Enter>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next" },
        ["<S-Tab>"] = { "select_prev" },
      },
      cmdline = {
        enabled = false
      },
      completion = {
        menu = { border = "single" },
        documentation = {
          auto_show_delay_ms = 0,
          window = {
            border = "single",
          },
          auto_show = false,
        },
        trigger = {
          show_in_snippet = true,
          show_on_trigger_character = true,
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "single",
        },
      },
      sources = {
        providers = {
          lsp = {
            async = true
          },
        },
        default = { "lsp", "path", "snippets", "buffer" }, --BUG:with lsp as source ts_ls is so slow
      },
    },
  },
}
