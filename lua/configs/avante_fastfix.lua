-- lua/configs/avante_fastfix.lua
-- 目的：
-- 1) 修復 E5560: Vimscript function must not be called in a fast event context
--    → fast event 期間避免呼叫 vim.fn.getenv，改用 vim.env / os.getenv。
-- 2) 對 ACP client 的 callback / message handler 做 schedule_wrap，
--    避免 fast event 觸發 UI/函式限制。
-- 3) 一些保命用的 pcall 與穩定性護欄。

local M = {}

-- 1) getenv 安全 shim：fast event 期間不用 vim.fn.getenv
do
  local original_getenv = vim.fn.getenv
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.getenv = function(name)
    -- fast event 期間直接讀 Lua/OS 環境，避免觸發 Vimscript 函式限制
    if vim.in_fast_event() then
      local v = vim.env[name]
      if v ~= nil then return v end
      v = os.getenv(name)
      return v or ""
    end
    -- 非 fast event 就走原始路徑
    return original_getenv(name)
  end
end

-- 2) 包裝 ACP client 的即時回呼，避免在 fast event 內呼叫 vim.fn/顯示 UI
local function schedule_wrap_member(tbl, key)
  if not tbl then return end
  local f = rawget(tbl, key)
  if type(f) == "function" then
    tbl[key] = vim.schedule_wrap(f)
  end
end

-- 3) 嘗試包裝 avante.libs.acp_client 內與 fast event 相關的函式
do
  local ok_acp, acp = pcall(require, "avante.libs.acp_client")
  if ok_acp and type(acp) == "table" then
    -- 根據你貼的 stack trace，這幾個點常出現於 fast event 路徑
    schedule_wrap_member(acp, "_handle_message")
    schedule_wrap_member(acp, "on_message")
    schedule_wrap_member(acp, "connect")
    schedule_wrap_member(acp, "start")
  end
end

-- 4) 防禦性處理：fast event 期間的通知，統一排到主迴圈
do
  local original_notify = vim.notify
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, level, opts)
    if vim.in_fast_event() then
      return vim.schedule(function()
        original_notify(msg, level, opts)
      end)
    else
      return original_notify(msg, level, opts)
    end
  end
end

return M

