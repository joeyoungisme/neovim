require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",  -- lazy.nvim 完成後
  callback = function()
    -- 1) 確保外掛載入（用 lazy.nvim 的程式化載入）
    pcall(function()
      require("lazy").load({ plugins = { "vim-visual-multi" } })
    end)

    -- 2) 可選：確認 <Plug> 真的存在（你也可以在命令列用 :verbose nmap <Plug>(VM-Find-Under) 看）
    -- 3) 先清掉任何人佔用 <C-n>
    pcall(vim.keymap.del, "n", "<C-n>")
    pcall(vim.keymap.del, "x", "<C-n>")

    -- 4) 重新綁定到 <Plug>（一定要 remap = true）
    vim.keymap.set({ "n", "x" }, "<C-n>", "<Plug>(VM-Find-Under)", { silent = true, remap = true })
  end,
})

vim.keymap.set("n", "<F8>", "<cmd>AerialToggle!<CR>", {
  desc = "Toggle Aerial outline",
  silent = true,
})

-- F9：切換右側檔案樹（nvim-tree）
vim.keymap.set("n", "<F9>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle File Tree (Right)" })

-- F10: 打開 nvim-tree 在右邊，並且聚焦到目前檔案
vim.keymap.set("n", "<F10>", function()
  local api = require("nvim-tree.api")
  -- 直接用 toggle，加上 find_file 與 focus 兩個參數
  -- api.tree.toggle({ find_file = true, focus = true })
  api.tree.toggle({ find_file = true })
end, { silent = true, desc = "Toggle NvimTree (right) & focus current file" })

-- Trouble：更好看的診斷/引用/Quickfix
vim.keymap.set("n", "<leader>xx", ":Trouble diagnostics toggle<CR>", { silent = true, desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xq", ":Trouble qflist toggle<CR>",       { silent = true, desc = "Quickfix" })
vim.keymap.set("n", "<leader>xr", ":Trouble lsp_references toggle<CR>",{ silent = true, desc = "LSP Refs" })

-- Telescope：常用搜尋
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true, desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>",  { silent = true, desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>",    { silent = true, desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>",  { silent = true, desc = "Help" })

-- multicursors.nvim: bind <C-n> to select word
--local ok, mc = pcall(require, "multicursors")
--if ok then
--  vim.keymap.set("n", "<C-n>", function() mc.operator() end,
--    { noremap = true, silent = true, desc = "Multi Select Word" })
--end

---- REQUIREMENTS:
-- 1) 已安裝並啟用 clangd（LSP）
-- 2) 已安裝 telescope.nvim
-- 3) ripgrep (rg) 在系統路徑，用於 live_grep

local tb  = require("telescope.builtin")
local lsp = vim.lsp.buf
local function cword() return vim.fn.expand("<cword>") end
local function cfile() return vim.fn.expand("<cfile>") end

-- zs: cscope "s" (symbol) → 在整個 workspace 搜尋符號名稱
vim.keymap.set("n", "ls", function()
  tb.lsp_workspace_symbols({ query = cword() })       -- 以當前單字為查詢
end, { silent = true, desc = "LSP: workspace symbol search" })

-- zg: cscope "g" (definition) → 跳到定義
vim.keymap.set("n", "lg", lsp.definition,
  { silent = true, desc = "LSP: go to definition" })

-- zc: cscope "c" (callers) → 誰呼叫我（Incoming Calls）
vim.keymap.set("n", "lc", function()
  -- 需要 clangd 支援 callHierarchy
  tb.lsp_incoming_calls()
end, { silent = true, desc = "LSP: incoming calls (callers)" })

-- zd: cscope "d" (callee) → 我呼叫誰（Outgoing Calls）
vim.keymap.set("n", "ld", function()
  tb.lsp_outgoing_calls()
end, { silent = true, desc = "LSP: outgoing calls (callees)" })

-- zt: cscope "t" (text) → 全域文字搜尋（以當前字）
vim.keymap.set("n", "lt", function()
  tb.live_grep({ default_text = cword() })
end, { silent = true, desc = "Text search (ripgrep)" })

-- ze: cscope "e" (egrep) → 正則文字搜尋（給你輸入 regex；預填目前字）
vim.keymap.set("n", "le", function()
  tb.live_grep({ default_text = cword(), additional_args = { "--pcre2" } })
end, { silent = true, desc = "Regex search (egrep-like)" })

-- zf: cscope "f" (filename) → 找檔案（以 <cfile> 預填）
vim.keymap.set("n", "lf", function()
  tb.find_files({ default_text = cfile() })
end, { silent = true, desc = "Find file by name" })

-- zi: cscope "i" (includes) → 搜尋包含此檔/標頭的 #include（近似）
-- zi: search who includes this file/header
vim.keymap.set("n", "li", function()
  local f = cfile()
  if f == nil or f == "" then f = cword() end
  tb.live_grep({
    default_text = f,
    additional_args = function()
      return {
        "--pcre2",
        "-e", "#include\\s*[\"<]" .. vim.pesc(f) .. "[\">]"
      }
    end,
  })
end, { silent = true, desc = "Search #include of current file" })

-- C & C++ runtime debug ---

local dap, dapui = require("dap"), require("dapui")

-- 開始/繼續
vim.keymap.set("n", "<leader>dc", function() dap.continue() end,
  { desc = "DAP: Continue / Start Debug" })

-- 跑到游標
vim.keymap.set("n", "<leader>dr", function() dap.run_to_cursor() end,
  { desc = "DAP: Run to Cursor" })

-- 斷點
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end,
  { desc = "DAP: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end,
  { desc = "DAP: Set Conditional Breakpoint" })

-- 單步
vim.keymap.set("n", "<leader>do", function() dap.step_over() end,
  { desc = "DAP: Step Over" })
vim.keymap.set("n", "<leader>di", function() dap.step_into() end,
  { desc = "DAP: Step Into" })
vim.keymap.set("n", "<leader>dO", function() dap.step_out() end,
  { desc = "DAP: Step Out" })

-- UI 面板
vim.keymap.set("n", "<leader>du", function() dapui.toggle() end,
  { desc = "DAP: Toggle UI" })

-- Evaluate 表達式（浮窗）
vim.keymap.set("n", "<leader>de", function() require("dap.ui.widgets").hover() end,
  { desc = "DAP: Evaluate Expression" })


-- 保留 z* 作為 cscope 快捷鍵
-- s: symbol、g: definition、c: callers、d: callees、t: text
vim.keymap.set("n", "zs", function()
  vim.cmd("Cscope find s " .. cword())
end, { silent = true, desc = "cscope: find symbol" })

vim.keymap.set("n", "zg", function()
  vim.cmd("Cscope find g " .. cword())
end, { silent = true, desc = "cscope: go to definition" })

vim.keymap.set("n", "zc", function()
  vim.cmd("Cscope find c " .. cword())
end, { silent = true, desc = "cscope: callers" })

vim.keymap.set("n", "zd", function()
  vim.cmd("Cscope find d " .. cword())
end, { silent = true, desc = "cscope: callees" })

vim.keymap.set("n", "zt", function()
  vim.cmd("Cscope find t " .. cword())
end, { silent = true, desc = "cscope: text search" })

-- （可選）視覺模式：直接用選取字串搜尋
vim.keymap.set("x", "zs", function()
  local sel = vim.fn.escape(vim.fn.getreg("v", 1, true), " ")
  vim.cmd("Cscope find s " .. sel)
end, { silent = true, desc = "cscope: find symbol (visual)" })

