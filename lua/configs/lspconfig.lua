-- Neovim 0.11+ 純內建 LSP 設定（不再 require 'lspconfig'）
-- 含 Zephyr 專案偵測與 clangd 參數自動切換

-- ===== 通用 on_attach / capabilities =====
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" } -- 與 clangd 一致

local function on_attach(_, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  -- 你的常用鍵
  map("n", "z-g", vim.lsp.buf.definition, "Go to Definition")
  map("n", "z-s", vim.lsp.buf.references, "Find References")
  map("n", "gD",  vim.lsp.buf.declaration, "Go to Declaration")
  map("n", "gi",  vim.lsp.buf.implementation, "Go to Implementation")
  map("n", "gt",  vim.lsp.buf.type_definition, "Type Definition")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("n", "K",   vim.lsp.buf.hover, "Hover Docs")
  map("n", "gl",  vim.diagnostic.open_float, "Line Diagnostics")

  -- Telescope（若已安裝）
  local ok, tb = pcall(require, "telescope.builtin")
  if ok then
    map("n", "gr", tb.lsp_references,               "Telescope References")
    map("n", "gd", tb.lsp_definitions,              "Telescope Definitions")
    map("n", "gI", tb.lsp_implementations,          "Telescope Implementations")
    map("n", "gT", tb.lsp_type_definitions,         "Telescope Type Defs")
    map("n", "<leader>ds", tb.lsp_document_symbols, "Doc Symbols")
    map("n", "<leader>ws", tb.lsp_dynamic_workspace_symbols, "WS Symbols")
  end

  -- 返回上一跳 / 前進
  vim.keymap.set("n", "<C-t>", "<C-o>", { buffer = bufnr, silent = true, desc = "Jump Back" })
  vim.keymap.set("n", "<A-t>", "<C-i>", { buffer = bufnr, silent = true, desc = "Jump Forward" })
end

-- ===== 小工具：尋找專案 root、檢測 Zephyr、組合路徑 =====
local function dirname(p) return vim.fs.dirname(p) end

local function project_root(fname)
  local f = (fname and #fname > 0) and fname or vim.api.nvim_buf_get_name(0)
  local dir = dirname(f)
  local markers = { "west.yml", "CMakeLists.txt", ".git" }
  local found = vim.fs.find(markers, { upward = true, path = dir })[1]
  return found and dirname(found) or vim.loop.cwd()
end

local function join(a, b)
  return (a:gsub("/+$","")) .. "/" .. (b:gsub("^/+",""))
end

local function exists_file(p)
  return vim.fn.filereadable(p) == 1
end

local function exists_dir(p)
  return vim.fn.isdirectory(p) == 1
end

local function is_zephyr_root(root)
  local zb = vim.env.ZEPHYR_BASE
  if not (zb and #zb > 0 and exists_dir(zb) == 1) then return false end
  return exists_file(join(root, "build/compile_commands.json"))
end

-- 依是否 Zephyr 專案回傳對應 clangd cmd
local function clangd_cmd_for(root)
  if is_zephyr_root(root) then
    -- 請依你的 SDK 安裝調整（支援萬用字元）
    local query_driver = "/opt/zephyr-sdk/*/bin/arm-zephyr-eabi-*"
    -- 例如：/home/joeyoung/Zephyr/zephyr-sdk-0.16.4/*/bin/arm-zephyr-eabi-*
    return {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=never",
      "--offset-encoding=utf-16",
      "--compile-commands-dir=" .. join(root, "build"),
      "--query-driver=" .. query_driver,
    }
  else
    -- 一般 C/C++ 專案
    return {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=never",
      "--offset-encoding=utf-16",
    }
  end
end

-- ===== 使用 Neovim 0.11 的新 API 定義與啟用 =====

-- 定義 clangd 設定
vim.lsp.config["clangd"] = {
  cmd = clangd_cmd_for(project_root(vim.api.nvim_buf_get_name(0))),
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = { clangdFileStatus = true, semanticHighlighting = true },

  -- 讓不同專案開 buffer 時能重新決定 root/cmd（避免固定死）
  on_new_config = function(new_config, new_root)
    new_config.cmd = clangd_cmd_for(new_root or project_root(vim.api.nvim_buf_get_name(0)))
  end,
}

-- 啟用（如果你還有其他 server，也一併加進來）
vim.lsp.enable({ "clangd" })

-- nvim-tree 自動追隨目前檔案（保留）
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ok_api, api = pcall(require, "nvim-tree.api")
    if ok_api and api.tree.is_visible() then
      api.tree.find_file({ open = true, focus = false })
    end
  end,
})

