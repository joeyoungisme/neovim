-- ~/.config/nvim/init.lua

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "git@github.com:folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"
lazy_config.git = lazy_config.git or {}
lazy_config.git.url_format = "git@github.com:%s.git"

require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- 存檔前：強制 UNIX 行尾並清除行尾 CR
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.bo.fileformat = "unix"
    vim.cmd([[%s/\r$//ge]])
  end,
})
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix" }

