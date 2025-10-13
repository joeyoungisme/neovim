-- ~/.config/nvim/lua/configs/lsp_clangd_zephyr.lua
-- 負責：偵測 Zephyr 專案並以「完整 build 的 compile_commands」啟動 clangd
-- 若非 Zephyr 專案，退回 generic 設定

local M = {}

local function path_join(a, b)
  return (a:gsub("/+$", "")) .. "/" .. (b:gsub("^/+", ""))
end

local function file_exists(p)
  return vim.fn.filereadable(p) == 1
end

local function dir_exists(p)
  return vim.fn.isdirectory(p) == 1
end

local function detect_zephyr_root(fname)
  local util = require("lspconfig.util")
  -- 以 west.yml 或 CMakeLists.txt 當 root，否則 .git
  return util.root_pattern("west.yml", "CMakeLists.txt", ".git")(fname)
end

local function is_zephyr_project(fname)
  local zb = os.getenv("ZEPHYR_BASE")
  if not zb or zb == "" or dir_exists(zb) == 0 then
    return false
  end
  local root = detect_zephyr_root(fname or vim.api.nvim_buf_get_name(0))
  if not root then return false end
  -- build 目錄存在且有 compile_commands.json
  local cc = path_join(root, "build/compile_commands.json")
  return file_exists(cc)
end

local function zephyr_cmd(build_dir)
  -- 注意：請把下面的 toolchain 路徑改成你的實際安裝位置（可用萬用字元）
  local query_driver = "/opt/zephyr-sdk/*/bin/arm-zephyr-eabi-*"
  -- 若你裝在 /home/joeyoung/Zephyr/zephyr-sdk-0.16.4，改成：
  -- local query_driver = "/home/joeyoung/Zephyr/zephyr-sdk-0.16.4/*/bin/arm-zephyr-eabi-*"

  return {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--offset-encoding=utf-16",
    "--compile-commands-dir=" .. build_dir,
    "--query-driver=" .. query_driver,
  }
end

M.setup = function(lspconfig, base)
  local util = require("lspconfig.util")

  -- root 規則：west.yml / CMakeLists.txt / .git
  local function root_dir(fname)
    return detect_zephyr_root(fname) or vim.loop.cwd()
  end

  -- on_attach：在 Zephyr 專案時，把 ZEPHYR_BASE 的幾個資料夾加進 workspace
  local function on_attach(client, bufnr)
    base.on_attach(client, bufnr)
    local zb = os.getenv("ZEPHYR_BASE")
    if zb and dir_exists(zb) == 1 then
      local add = vim.lsp.buf.add_workspace_folder
      pcall(add, zb)
      pcall(add, path_join(zb, "include"))
      pcall(add, path_join(zb, "drivers"))
      pcall(add, path_join(zb, "kernel"))
      pcall(add, path_join(zb, "soc"))
      pcall(add, path_join(zb, "lib"))
    end
  end

  lspconfig.clangd.setup({
    on_attach = on_attach,
    capabilities = base.capabilities,
    root_dir = root_dir,
    init_options = { clangdFileStatus = true, semanticHighlighting = true },

    cmd = (function()
      -- 以目前工作目錄猜 root，再決定是否用 Zephyr 專用 cmd
      local fname = vim.api.nvim_buf_get_name(0)
      if is_zephyr_project(fname) then
        local root = detect_zephyr_root(fname) or vim.loop.cwd()
        local build_dir = path_join(root, "build")
        return zephyr_cmd(build_dir)
      else
        -- 非 Zephyr：使用 generic 設定
        return base.generic_clangd.cmd
          or { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never", "--offset-encoding=utf-16" }
      end
    end)(),
  })
end

return M

