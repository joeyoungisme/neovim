-- ~/.config/nvim/lua/configs/telescope.lua

local ok, telescope = pcall(require, "telescope")
if not ok then
  vim.notify("telescope not found", vim.log.levels.WARN)
  return
end

local actions = require("telescope.actions")

telescope.setup({
  -- ====== 全域預設設定（對所有 picker 生效） ======
  defaults = {
    -- ----- UI / 佈局設定 -----

    -- layout_strategy: 視窗安排方式
    -- 可選: "horizontal", "vertical", "center", "cursor", "flex"
    -- layout_strategy = "horizontal",

    -- layout_config: 針對不同 layout 的細部設定
    -- 百分比用 0.x 表示，或直接給絕對數值
    layout_config = {
      -- width = 0.9,     -- Telescope 視窗寬度比例
      -- height = 0.85,   -- 高度比例

      prompt_position = "top", -- "top" or "bottom"

      horizontal = {
        -- preview_width = 0.6,   -- 預覽視窗寬度比例
        -- preview_cutoff = 120,  -- 小於這個寬度就關閉 preview
      },

      vertical = {
        -- preview_height = 0.6,  -- 垂直 layout 下的預覽高度比例
        -- mirror = false,        -- 是否鏡像（上下互換）
      },

      center = {
        -- width = 0.5,
        -- height = 0.4,
        -- preview_cutoff = 40,
      },

      cursor = {
        -- width = 0.5,
        -- height = 0.4,
      },
    },

    -- sorting_strategy: 結果排序方向
    -- "ascending"  = 游標在上，結果由上往下
    -- "descending" = 游標在上，結果由下往上堆
    sorting_strategy = "ascending",

    -- scroll_strategy: 捲動模式
    -- "cycle" = 捲到底會回到頂
    -- "limit" = 捲到頂/底就停住
    -- scroll_strategy = "cycle",

    -- selection_strategy: 重新打開 picker 時，選取行為
    -- "reset" | "follow" | "row" | "closest"
    -- selection_strategy = "reset",

    -- initial_mode: 打開 Telescope 時預設模式
    -- "insert" 或 "normal"
    -- initial_mode = "insert",

    -- fname_width: 檔名欄寬度（部分 picker 有用）
    -- fname_width = 0,

    -- ----- 顯示字串 / 標記 -----

    -- prompt_prefix: 提示字元（輸入框前面那個）
    prompt_prefix = "  ",

    -- selection_caret: 選取列前面的符號
    selection_caret = " ",

    -- entry_prefix: 每列前面的字串（在 caret 後面）
    -- entry_prefix = "  ",

    -- multi_icon: 多選模式時顯示的 icon
    -- multi_icon = "+",

    -- results_title / prompt_title / preview_title:
    -- 各區塊標題，不設就是預設或空
    -- results_title = "Results",
    -- prompt_title  = "Prompt",
    -- preview_title = "Preview",

    -- winblend: 整個浮動視窗透明度 0~100（0 = 不透明）
    winblend = 40,

    -- border: 是否顯示邊框
    -- true / false
    -- border = true,

    -- borderchars: 邊框字元（左、右、上、下、左上、右上、右下、左下）
    -- borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },

    -- color_devicons: 是否顯示彩色 devicon 圖示
    -- color_devicons = true,

    -- use_less: 預覽是否用 less（通常不用改）
    -- use_less = true,

    -- set_env: 針對 Telescope buffer 設定環境變數
    -- set_env = { ["COLORTERM"] = "truecolor" },

    -- dynamic_preview_title: 預覽視窗的 title 是否跟著選取項目變動
    -- dynamic_preview_title = false,

    -- preview: 一些預覽相關細節
    preview = {
      -- hide_on_startup = false,     -- 打開 picker 時是否預設關閉 preview
      -- msg_bg_fill = true,         -- 訊息背景填滿
    },

    -- ----- 搜尋 / 忽略設定 -----

    -- vimgrep_arguments: live_grep / grep_string 時呼叫 rg 的參數
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      -- "--hidden",        -- 如需包含隱藏檔，可取消註解
    },

    -- file_ignore_patterns: 忽略哪些檔案或資料夾（lua pattern）
    file_ignore_patterns = {
      -- "%.o", "%.a", "%.out",    -- 目標檔 / 二進位
      -- "build/", "dist/",        -- build 資料夾
      -- "node_modules/",
      -- ".git/",
      -- ".cache/",
    },

    -- path_display: 路徑顯示方式
    -- 可用: "hidden", "tail", "smart", { "absolute" }, { "shorten" }, 或 function
    path_display = { "hidden" },

    -- follow: 是否跟隨符號連結
    -- follow = false,

    -- no_ignore: 設為 true 時會忽略 .gitignore 設定
    -- no_ignore = false,

    -- no_ignore_parent: 是否忽略 parent .gitignore
    -- no_ignore_parent = false,

    -- ----- 快取 / 歷史 -----

    -- cache_picker: 是否快取某些 picker 結果
    -- cache_picker = {
    --   num_pickers = 5,
    -- },

    -- history: 查詢歷史設定
    -- history = {
    --   path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
    --   limit = 100,
    -- },

    -- ----- Telescope 視窗裡的鍵盤 mapping -----

    mappings = {
      -- insert 模式
      i = {
        -- ["<C-j>"] = actions.move_selection_next,
        -- ["<C-k>"] = actions.move_selection_previous,
        -- ["<C-n>"] = actions.cycle_history_next,
        -- ["<C-p>"] = actions.cycle_history_prev,
        -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        -- ["<Esc>"] = actions.close,
      },

      -- normal 模式
      n = {
        -- ["q"] = actions.close,
        -- ["<C-j>"] = actions.move_selection_next,
        -- ["<C-k>"] = actions.move_selection_previous,
        -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
    },

    -- ----- 預設使用的 sorter / previewer（通常不用改） -----

    -- file_sorter = require("telescope.sorters").get_fuzzy_file,
    -- generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,

    -- file_previewer   = require("telescope.previewers").vim_buffer_cat.new,
    -- grep_previewer   = require("telescope.previewers").vim_buffer_vimgrep.new,
    -- qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    -- buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  },

  -- ====== 個別 picker 的設定（要再細調時用） ======
  pickers = {
    -- find_files = {
    --   theme = "dropdown",         -- 套用內建 theme: dropdown, cursor, ivy...
    --   previewer = false,          -- 關閉預覽以節省空間
    --   hidden = true,              -- 是否顯示隱藏檔
    -- },

    -- live_grep = {
    --   theme = "ivy",
    -- },

    -- buffers = {
    --   sort_lastused = true,
    --   theme = "dropdown",
    --   previewer = false,
    --   mappings = {
    --     i = {
    --       ["<C-d>"] = actions.delete_buffer,
    --     },
    --     n = {
    --       ["d"] = actions.delete_buffer,
    --     },
    --   },
    -- },

    -- help_tags = {
    --   theme = "dropdown",
    -- },
  },

  -- ====== extensions 的設定（你有裝什麼 extension 再加） ======
  extensions = {
    -- fzf = {
    --   fuzzy = true,
    --   override_generic_sorter = true,
    --   override_file_sorter = true,
    --   case_mode = "smart_case",  -- "smart_case", "ignore_case", "respect_case"
    -- },

    -- cscope = {
    --   -- 如果你有裝 telescope-cscope.nvim，可以在這裡設定
    -- },

    -- 其他 extension ...
  },
})

-- 如果有用 extension，要記得 load
-- pcall(telescope.load_extension, "fzf")
-- pcall(telescope.load_extension, "cscope")
