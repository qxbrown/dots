-- Rice — no Tokyo Night. Source this from your init.lua if you want the default colorscheme:
--   require("init-rice")  -- if this repo's config is in rtp
-- Or in init.lua before plugins: vim.g.rice_colorscheme = "habamax"
local scheme = vim.g.rice_colorscheme or "habamax"
vim.cmd(("colorscheme %s"):format(scheme))
