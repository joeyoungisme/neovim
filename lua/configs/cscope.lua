
-- lua/configs/cscope.lua
local ok, cscope_maps = pcall(require, "cscope_maps")
if not ok then
  vim.notify("cscope_maps not found!", vim.log.levels.WARN)
  return
end

cscope_maps.setup({
  disable_maps = true,
  cscope = {
    db_file = "./.cscope.out",
    exec = "cscope",
    picker = "telescope",
    project_rooter = { enable = true, change_cwd = false },
    db_build_cmd = { script = "default", args = { "-bqkv" } }, -- 自動在專案根建
    skip_picker_for_single_result = true,
  },
})

vim.api.nvim_create_user_command("CscopeRebuild", function()
  -- 簡單呼叫系統指令建立 DB（在專案根目錄執行）
  -- 你也可以改成用 gutentags 自動化
  vim.fn.jobstart({ "sh", "-c", "cscope -Rbq -f .cscope.out" }, {
    cwd = vim.fn.getcwd(),
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("cscope.out rebuilt", vim.log.levels.INFO)
        vim.cmd("Cscope reset")
        vim.cmd("Cscope db add " .. vim.fn.getcwd() .. " .cscope.out")
      else
        vim.notify("cscope rebuild failed", vim.log.levels.ERROR)
      end
    end,
  })
end, {})
