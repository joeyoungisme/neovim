local dap = require("dap")

-- codelldb adapter
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    -- 換成你的 codelldb adapter 實際路徑
    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}

-- C/C++ 啟動設定

dap.configurations.c = {
  {
    name = "Launch (LLDB / codelldb)",
    type = "codelldb",  -- 這裡一定要跟上面 adapter 的 key 一樣
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
    end,
    cwd = vim.fn.getcwd(),  -- 建議寫死 vim.fn.getcwd()，避免某些 adapter 不吃 ${workspaceFolder}
    stopOnEntry = false,
    args = {},
  },
}
dap.configurations.cpp = dap.configurations.c
