-- ~/.config/nvim/lua/plugins/init.lua

return {
  -- 格式化
  {
    "stevearc/conform.nvim",
    -- event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("configs.lspconfig")  -- <- 統一在這裡載入（內含 Zephyr 整合）
    end,
  },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
    },
    opts = {
      view = { side = "right", width = 34 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      git = { enable = false, ignore = false },
      update_focused_file = {
        enable = true,
        update_cwd = false,
        update_root = false,
        ignore_list = {},
      },
      sync_root_with_cwd = false,
      respect_buf_cwd = false,
    },
  },

  -- 符號側欄（可選）
  {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
      layout = { default_direction = "left", min_width = 32 },
      filter_kind = false,
      attach_mode = "global",
    },
  },

  -- Mason & Mason-lspconfig
  { "williamboman/mason.nvim", opts = {} },
  { "williamboman/mason-lspconfig.nvim", opts = { ensure_installed = { "clangd" } } },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c", "cpp", "make", "cmake", "json", "lua", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Trouble（診斷視圖）
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { use_diagnostic_signs = true },
  },

  -- Telescope（用於 LSP 導航）
  { "nvim-telescope/telescope.nvim", branch = "0.1.x" },

  -- DAP（可選）
  {
    "mfussenegger/nvim-dap",
    config = function()
      pcall(function() require "configs.dap-cpp" end)
    end,
  },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
  { "theHamsta/nvim-dap-virtual-text", opts = { commented = true } },

  -- 多光標（可選）
  {
    "mg979/vim-visual-multi",
    keys = { { "<C-n>", mode = { "n", "x" }, desc = "VM Find Under" } },
  },

  -- Avante（照你原本）
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()

      -- for OpenAI
--    require("avante").setup({
--    provider = "openai",  -- default provider
--    providers = {
--      openai = {
--        __inherited_from = "openai",
--        api_key = os.getenv("OPENAI_API_KEY"), -- put your sk-proj-... here
--        endpoint = "https://api.openai.com/v1", -- explicit endpoint
--        model = "gpt-5-nano",  -- exactly what your curl example uses
--        extra_request_body = {
--          temperature = 0.2,
--          max_tokens = 4096,
--        },
--      },
--    },
--  })
    --  for Claude
    require("avante").setup({
      -------------------------------------------------------------------
      -- 這一段是「直連 Claude API」的設定 (你目前使用的方式)
      -- provider = "claude",
      -- mode = "agentic",
      -- providers = {
      --   claude = {
      --     endpoint = "https://api.anthropic.com",
      --     model = "claude-sonnet-4-20250514", -- 模型 ID，取決於你帳號可用的版本
      --     timeout = 30000,
      --     disable_tools = true,  -- 關閉自動工具/跨檔操作
      --     extra_request_body = {
      --       temperature = 0.2,
      --       max_tokens = 4096,
      --     },
      --   },
      -- },
      -- system = [[
      -- 1) 只能針對當前專案( Project )的檔案進行修改
      -- 2) 禁止存取或修改專案根目錄之外的任何路徑。
      -- ]]
      -------------------------------------------------------------------
    
      -------------------------------------------------------------------
      -- 這一段是「ACP provider」(Claude Code CLI) 的設定
      -------------------------------------------------------------------
      -- default to ACP (Claude Code); you can switch at runtime
      provider = "claude-code",
      mode = "agentic",
    
      -------------------------------------------------------------------
      -- ACP providers (external agents, e.g. Claude Code)
      -------------------------------------------------------------------
      acp_providers = {
        ["claude-code"] = {
          command = "npx",
          args = { "@zed-industries/claude-code-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
            ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
          },
        },
      },
    
      -------------------------------------------------------------------
      -- HTTP providers (direct API; put OLLAMA here, not in acp_providers)
      -------------------------------------------------------------------
      providers = {
        ["ollama-llama3"] = {
          __inherited_from = "ollama",
          endpoint = "http://192.168.1.101:11434",
          model = "llama3:latest",
          timeout = 30000,
          extra_request_body = {
            options = {
              temperature = 0,
              num_predict = 2048,
            },
          },
        },
        ["ollama-qwen"] = {
          __inherited_from = "ollama",
          endpoint = "http://192.168.1.101:11434",
          model = "qwen2.5-coder:7b",
          timeout = 30000,
          extra_request_body = {
            options = {
              temperature = 0,
              num_predict = 2048,
            },
          },
        },
        ["ollama-codellama"] = {
          __inherited_from = "ollama",
          endpoint = "http://192.168.1.101:11434",
          model = "codellama:7b",
          timeout = 30000,
          extra_request_body = {
            options = {
              temperature = 0,
              num_predict = 2048,
            },
          },
        },
      },
    
      system = [[
          角色：你是資深 C 系統工程師，專長網路 I/O、epoll、非阻塞 socket 與可攜性建構。
          任務：先讀專案根目錄的 avante.md（或 Agent.md），未經確認不可假設未明規格。

          輸出節奏：
          回覆「澄清問題清單 ≤ 10 條」與「執行計劃（含分里程碑）」，不產程式碼；
          產出 DESIGN.md 的大綱與草稿；
          再開始產出 headers → 實作 → 測試程式 → Makefile；
          每步都給出風險與驗收清單；

          原則：
          優先正確性與可維護性，避免魔法常數與隱性共享狀態
          明確執行緒與回呼語義；所有 API/回呼要定義生命週期與錯誤碼
          如遇模糊處，一律提出 2–3 個選項（含利弊與推薦）再往下走
          回覆以條列、短句為主，拒絕一次輸出過大不可審查的內容
          風格：使用「必須/不得/應該」等規格語氣；章節清晰、帶小標題與核對清單
      ]],
    })

    -------------------------------------------------------------------
    -- 額外功能：匯出 AvanteChat 紀錄
    -------------------------------------------------------------------
    -- 取專案根：優先用 git root，否則用 cwd
    local function project_root()
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
      if vim.v.shell_error == 0 and git_root and #git_root > 0 then
        return git_root
      else
        return vim.fn.getcwd()
      end
    end
    
    -- 將當前 avante-chat buffer 的內容匯出為 markdown
    vim.api.nvim_create_user_command("AvanteExportChat", function()
      local buf = vim.api.nvim_get_current_buf()
      local ft  = vim.bo[buf].filetype
      if ft ~= "Avante" then
        vim.notify("請在 Avante Chat 視窗裡執行 :AvanteExportChat（目前 ft=" .. tostring(ft) .. "）", vim.log.levels.WARN)
        return
      end
    
      -- 讀取所有行（不會修改 buffer，不需要 modifiable=true）
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    
      -- 準備輸出目錄與檔名
      local root = project_root()
      local log_dir = root .. "/.avante_logs"
      vim.fn.mkdir(log_dir, "p")
      local filename = string.format("%s/chat_%s.md", log_dir, os.date("%Y%m%d_%H%M%S"))
    
      -- 直接寫檔：不觸發 BufWritePre/BufWritePost，也不依賴當前 buffer 狀態
      local ok, err = pcall(vim.fn.writefile, lines, filename, "b")
      if not ok then
        vim.notify("寫檔失敗: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
    
      vim.notify("✅ Avante chat 已匯出到： " .. filename, vim.log.levels.INFO)
    end, {})
  
    -------------------------------------------------------------------
    -- 額外功能：批次對資料夾檔案呼叫 AvanteEdit
    -------------------------------------------------------------------
    local function AvanteBatchEdit(dir, pattern, instr)
      local files = vim.fn.globpath(dir, pattern, false, true)
      for _, f in ipairs(files) do
        vim.cmd("edit " .. vim.fn.fnameescape(f))
        vim.cmd("normal! ggVG")
        vim.cmd('AvanteEdit ' .. instr)
      end
    end
  
    vim.api.nvim_create_user_command("AvanteBatchEdit", function(opts)
      local args = vim.split(opts.args, " ")
      local dir = args[1]
      local pattern = args[2]
      local instr = table.concat(args, " ", 3)
      AvanteBatchEdit(dir, pattern, instr)
    end, { nargs = "+" })

    vim.api.nvim_create_user_command("AvanteClose", function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        if ft == "avante-chat" then
          vim.api.nvim_win_close(win, true)
        end
      end
      print("✅ Avante Chat 視窗已全部關閉")
    end, {})

    -- 一鍵切 Ollama + legacy（不走 ACP，並斷掉 ACP 連線）
    vim.api.nvim_create_user_command("AvOllamaLegacy", function()
      -- 先切模式，避免進 ACP 路徑
      require("avante.config").override({ mode = "legacy" })
      -- 切換到你的 Ollama provider（這裡用 qwen；也可改成你想要的 ollama-llama3）
      require("avante.api").switch_provider("ollama-qwen")
      -- 雙保險：把 ACP 客戶端斷掉，避免背景訊息再進來
      pcall(function() require("avante.libs.acp_client").disconnect() end)
      vim.notify("Avante → provider=ollama-qwen, mode=legacy (ACP disabled)", vim.log.levels.INFO)
    end, {})
    
    -- 一鍵切回 Claude Code（ACP）+ agentic
    vim.api.nvim_create_user_command("AvClaudeAgentic", function()
      require("avante.config").override({ mode = "agentic" })
      require("avante.api").switch_provider("claude-code")
      vim.notify("Avante → provider=claude-code, mode=agentic (ACP enabled)", vim.log.levels.INFO)
    end, {})

    end,
  },
}

