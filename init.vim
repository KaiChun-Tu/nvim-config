" 基礎設定
set nocompatible
set number
set relativenumber
syntax on
filetype plugin indent on

" 設定 Leader 鍵為空格
let mapleader = " "
let maplocalleader = " "
" ============================================
" 分頁相關的快捷鍵
" ============================================
" 注意: Ctrl+h/j/k/l 已保留給 vim-tmux-navigator
" 注意: Ctrl+n 已被 Neo-tree 使用
nnoremap <C-t> :tabnew<CR>              " Ctrl+t 創建新分頁
nnoremap <leader>m :tabnext<CR>         " Space+m 下一個分頁
nnoremap <leader>n :tabprevious<CR>     " Space+n 上一個分頁
nnoremap <D-c> "+y                      " Command+c 複製到系統剪貼簿
nnoremap <leader>tc :tabclose<CR>       " Space+t+c 關閉當前分頁
nnoremap gt <Nop>
nnoremap gT <Nop>
nnoremap sd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap st <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
nnoremap si <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
nnoremap sD <cmd>lua require('goto-preview').goto_preview_declaration()<CR>
nnoremap sc <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap sr <cmd>lua require('goto-preview').goto_preview_references()<CR>
" lazy.nvim 安裝設定
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 編輯體驗設定
vim.opt.scrolloff = 5
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.g.sleuth_automatic = 0

-- 顯示設定
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- 搜尋設定
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 系統整合
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- 持久化 undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 分割視窗設定
vim.opt.splitright = true
vim.opt.splitbelow = true

-- 更新時間 (影響 swap 寫入和 CursorHold)
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.cmd([[
  highlight DiffAdd guibg=#355535 guifg=NONE      " 更亮的綠色
  highlight DiffChange guibg=#354555 guifg=NONE    " 更亮的藍色
  highlight DiffDelete guibg=#553535 guifg=NONE    " 更亮的紅色
  highlight DiffText guibg=#405565 guifg=NONE      " 更明顯的藍色
]])
-- 配置插件
require("lazy").setup({
  {
    "github/copilot.vim",
    lazy = false,
    priority = 1000,
  },
  -- 主題
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 500,
    config = function()
        -- 設定背景為深色
        vim.g.gruvbox_material_background = 'hard'  -- 可選: 'hard', 'medium', 'soft'
        -- 設定前景色對比度
        vim.g.gruvbox_material_foreground = 'material'  -- 可選: 'material', 'mix', 'original'
        -- 啟用斜體
        vim.g.gruvbox_material_enable_italic = true
        -- 啟用粗體
        vim.g.gruvbox_material_enable_bold = true
        -- 設定為透明背景
        vim.g.gruvbox_material_transparent_background = 1
        -- 應用主題
        vim.cmd.colorscheme('gruvbox-material')
        -- 自定義行號顏色
        vim.cmd([[
          highlight LineNr guifg=#7c6f64 ctermfg=243
          highlight CursorLineNr guifg=#fe8019 gui=bold ctermfg=208 cterm=bold
        ]])
    end
  },
  -- gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- 導航到下一個或上一個修改
          vim.keymap.set("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, {expr=true, buffer=bufnr})

          vim.keymap.set("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, {expr=true, buffer=bufnr})

          -- 查看當前行的 Git 歷史
          vim.keymap.set("n", "<leader>gh", gs.preview_hunk_inline, {buffer = bufnr})

          -- 查看文件的 Git blame 信息
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line{full=true} end, {buffer = bufnr})
        end,
      })
    end
  },

  -- diffview.nvim
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("diffview").setup({
        -- 配置選項
      })
      vim.keymap.set("n", "<leader>dv", ":DiffviewOpen<CR>")
      vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>")
    end
  },
  --nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "query", "python", "javascript", "typescript", "html", "css" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental = "<C-backspace>",
          },
        },
        fold = {enable = true},
      })

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = true
      vim.opt.foldlevel = 0
    end,
  },
  -- toggleterm.nvim
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      local Terminal = require('toggleterm.terminal').Terminal
      
      local term = Terminal:new({
        count = 1,
        direction = "float",
      })

      function _G.toggle_term_direction()
        if term.direction == "float" then
          term:close()
          term.direction = "horizontal"
          term:open()
        else
          term:close()
          term.direction = "float"
          term:open()
        end
      end

      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = {
          border = "curved",
          winblend = 0,
        },
        highlights = {
          FloatBorder = {
            guifg = "#fe8019",
          },
        },
        shade_terminals = false,
        shading_factor = 0,
      })

      vim.api.nvim_create_user_command('Td', function()
        toggle_term_direction()
      end, {})
    end
  },
  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } -- 可選，但推薦
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      
      telescope.setup({
        defaults = {
          -- 添加這些設定
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
          file_sorter = require("telescope.sorters").get_fuzzy_file(),
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          
          -- 設定檔案搜索的起始目錄
          cwd = function()
            local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
            if vim.v.shell_error == 0 then
              return git_dir
            else
              return vim.fn.getcwd()
            end
          end,

          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git",
            ".next",
            "dist",
            "build"
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
          }
        }
      })
      
      -- 載入 fzf 支援
      telescope.load_extension('fzf')

      -- 自定義 Telescope 選擇顏色（使用 Gruvbox 橘色）
      vim.cmd([[
        highlight TelescopeSelection guibg=#504945 guifg=#fe8019 gui=bold
        highlight TelescopeSelectionCaret guifg=#fe8019 guibg=#504945
        highlight TelescopeMultiSelection guibg=#3c3836 guifg=#fe8019
      ]])

      -- 設定快捷鍵
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', 'ff', function()
          builtin.find_files({
              cwd = vim.fn.getcwd(),
          })
      end, {})
    end
  },
  -- noice.nvim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
      messages={
       enabled = false,
      }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
      }
  },

  -- 語法高亮 (優先載入)
  {
    "sheerun/vim-polyglot",
    lazy = false,
    priority = 900,
  },

  {
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    }
  },

  -- 自動偵測縮排 (在 polyglot 之後載入)
  {
    "tpope/vim-sleuth",
    lazy = false,
    priority = 800,
  },

  -- 啟動畫面
  {
    "mhinz/vim-startify",
    lazy = false,
    priority = 100,
  },
  -- LSP
  -- Note: nvim-lspconfig plugin is no longer needed for Neovim 0.11+
  -- Using built-in vim.lsp.config API instead
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  -- 文件樹
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({})
      vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>')
    end
  },
  -- 狀態列
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        theme = 'gruvbox-material'
      })
    end
  },
  -- 縮排指示線
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end
  },
  -- HTML 標籤自動關閉
  {
    "docunext/closetag.vim",
    ft = {'html', 'xhtml', 'xml', 'htmldjango'},
    config = function()
      vim.cmd[[
        autocmd FileType html,htmldjango let b:closetag_html_style=1
      ]]
    end,
  },

  -- 自動配對
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
          java = false,
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- 程式碼摺疊
  { "tmhedberg/SimpylFold" },

  -- 語法檢查
  { "w0rp/ale" },

  -- Pug 支援
  { "digitaltoad/vim-pug" },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          -- Ctrl+j/k 只在補全菜單顯示時有效，否則讓給 vim-tmux-navigator
          ['<C-j>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()  -- 讓給 vim-tmux-navigator
            end
          end, { 'i', 's' }),
          ['<C-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()  -- 讓給 vim-tmux-navigator
            end
          end, { 'i', 's' }),
          -- 使用 Ctrl+n/p 作為補全導航的替代方案
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              fallback()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  --leetcode.nvim
  {
      "kawre/leetcode.nvim",
      dependencies = {
          "nvim-telescope/telescope.nvim",
          "nvim-lua/plenary.nvim",
          "MunifTanjim/nui.nvim",
      },
      opts = {
          lang = "cpp",
          cn = {
              enabled = false,
          },
          theme = {
              [""] = { fg = "#d4be98" },
              normal = { fg = "#d4be98" },
              alt = { fg = "#a89984" },
          },
      },
      config = function(_, opts)
          require("leetcode").setup(opts)
          vim.api.nvim_create_user_command("Lt", "Leet test", {})
          vim.api.nvim_create_user_command("Ls", "Leet submit", {})
      end,
  },
  -- mini.ai
  {
    "echasnovski/mini.ai",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({
        n_lines = 500,
        custom_textobjects = {
          f = require("mini.ai").gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner"
          }, {}),
          c = require("mini.ai").gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner"
          }, {}),
          o = require("mini.ai").gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
        },
      })
    end,
  },

  -- smart-splits.nvim
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
        ignored_buftypes = { "nofile" },
        default_amount = 3,
        at_edge = "wrap",
        move_cursor_same_row = false,
        cursor_follows_swapped_bufs = false,
        resize_mode = {
          quit_key = "<ESC>",
          resize_keys = { "h", "j", "k", "l" },
          silent = false,
          hooks = {
            on_enter = nil,
            on_leave = nil,
          },
        },
        ignored_events = {
          "BufEnter",
          "WinEnter",
        },
        multiplexer_integration = nil,
        disable_multiplexer_nav_when_zoomed = true,
      })

      vim.keymap.set("n", "<C-Left>", require("smart-splits").move_cursor_left)
      vim.keymap.set("n", "<C-Down>", require("smart-splits").move_cursor_down)
      vim.keymap.set("n", "<C-Up>", require("smart-splits").move_cursor_up)
      vim.keymap.set("n", "<C-Right>", require("smart-splits").move_cursor_right)
      vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
      vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
      vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
      vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
    end,
  },

  -- flash.nvim
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        multi_window = true,
        forward = true,
        wrap = true,
        incremental = false,
      },
      jump = {
        jumplist = true,
        pos = "start",
        history = false,
        register = false,
        nohlsearch = false,
        autojump = false,
      },
      label = {
        uppercase = true,
        rainbow = {
          enabled = false,
          shade = 5,
        },
      },
      modes = {
        search = {
          enabled = false,  -- 禁用搜索模式，避免干扰 / 搜索
        },
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
    keys = {
      { "<leader>s", mode = { "n", "x", "o" }, function()
        require("flash").jump()
      end, desc = "Flash Jump" },
      { "<leader>S", mode = { "n", "x", "o" }, function()
        require("flash").treesitter()
      end, desc = "Flash Treesitter" },
      { "r", mode = "o", function()
        require("flash").remote()
      end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function()
        require("flash").treesitter_search()
      end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function()
        require("flash").toggle()
      end, desc = "Toggle Flash Search" },
    },
  },

  -- goto-preview
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    config = true,
  },

  -- vim-tmux-navigator
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<leader>p", "<cmd>TmuxNavigatePrevious<cr>" },
    },
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
      })

      wk.add({
        { "<leader>c", group = "Code" },
        { "<leader>ca", desc = "Code Action" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>dd", desc = "Show Diagnostics" },
        { "<leader>dv", desc = "Diffview Open" },
        { "<leader>dc", desc = "Diffview Close" },
        { "<leader>e", desc = "Show Line Diagnostics" },
        { "<leader>f", desc = "Format Code" },
        { "<leader>g", group = "Git" },
        { "<leader>gb", desc = "Git Blame" },
        { "<leader>gh", desc = "Git Hunk Preview" },
        { "<leader>h", desc = "Highlight Word Toggle" },
        { "<leader>n", desc = "Next Tab" },
        { "<leader>m", desc = "Previous Tab" },
        { "<leader>p", desc = "Tmux Navigate Previous" },
        { "<leader>r", group = "Rename" },
        { "<leader>rn", desc = "Rename Symbol" },
        { "<leader>s", desc = "Flash Jump" },
        { "<leader>S", desc = "Flash Treesitter" },
        { "<leader>t", group = "Tab" },
        { "<leader>tc", desc = "Close Tab" },
        { "<leader>w", group = "Workspace" },
        { "<leader>ws", desc = "Workspace Symbols" },
        { "s", group = "Preview" },
        { "sd", desc = "Preview Definition" },
        { "st", desc = "Preview Type Definition" },
        { "si", desc = "Preview Implementation" },
        { "sD", desc = "Preview Declaration" },
        { "sc", desc = "Close Previews" },
        { "sr", desc = "Preview References" },
        { "g", group = "Go to" },
        { "gt", desc = "Go to Definition" },
        { "gr", desc = "References" },
        { "gi", desc = "Implementation" },
        { "gs", desc = "Document Symbols" },
        { "gb", desc = "Go Back" },
        { "f", group = "Find" },
        { "ff", desc = "Find Files" },
        { "[", group = "Previous" },
        { "[c", desc = "Previous Git Change" },
        { "[d", desc = "Previous Diagnostic" },
        { "]", group = "Next" },
        { "]c", desc = "Next Git Change" },
        { "]d", desc = "Next Diagnostic" },
        { "<A-h>", desc = "Resize Split Left" },
        { "<A-j>", desc = "Resize Split Down" },
        { "<A-k>", desc = "Resize Split Up" },
        { "<A-l>", desc = "Resize Split Right" },
      })
    end,
  },
})

-- Disable ALE's LSP support since we're using native Neovim LSP
vim.g.ale_disable_lsp = 1
EOF

imap <silent><script><expr> <C-L> copilot#Accept("\<CR>")

" 高亮設定
let g:word_highlight_active = 0
let g:current_word = ''

" 自定義高亮顏色
highlight WordHighlight guibg=#504945 guifg=#fe8019 gui=bold ctermbg=239 ctermfg=208 cterm=bold

function! HighlightWordToggle()
    let l:word = expand('<cword>')
    
" 如果沒有單字，直接返回
    if empty(l:word)
        echo "No word under cursor"
        return
    endif
    
" 如果是同一個單字，關閉高亮
    if l:word == g:current_word && g:word_highlight_active
        let g:word_highlight_active = 0
        let g:current_word = ''
        match none
        redraw
        echo "Highlight OFF"
        return
    endif
    
    " 高亮新單字
    let g:word_highlight_active = 1
    let g:current_word = l:word
    execute printf('match WordHighlight /\V\<%s\>/', escape(l:word, '/\'))
    
    " 顯示提示信息
    redraw
    echohl WarningMsg
    echo "Highlighting: " . l:word
    echohl None
endfunction

" 清除高亮的函數
function! ClearHighlight()
    let g:word_highlight_active = 0
    let g:current_word = ''
    match none
endfunction

" ============================================
" 高亮單詞切換
" ============================================
" Ctrl+h 已保留給 vim-tmux-navigator，改用 <leader>hw
nnoremap <silent> <leader>h :call HighlightWordToggle()<CR>

" 可選：ESC 清除高亮
" nnoremap <silent> <ESC> :call ClearHighlight()<CR>
lua << EOF
-- LSP 設定
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "lua_ls",
  },
  automatic_installation = true,
  handlers = {
    -- Disable default handler to prevent auto-setup
    function(server_name)
      -- Do nothing - we'll set up servers manually below
    end,
  },
})

-- LSP 伺服器設定
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSP 快捷鍵設定（使用 LspAttach autocmd）
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
    vim.keymap.set('n', 'gt', require('telescope.builtin').lsp_definitions, opts)
    vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations, opts)
    vim.keymap.set('n', 'gs', require('telescope.builtin').lsp_document_symbols, opts)
    vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_workspace_symbols, opts)
    vim.keymap.set('n', '<leader>dd', require('telescope.builtin').diagnostics, opts)
    vim.keymap.set('n', 'gb', '<C-o>', opts)

    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  end
})

-- Pyright 設定
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    ".git",
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile"
  },
  single_file_support = true,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "basic",
        extraPaths = {
          vim.fn.getcwd(),
          vim.fn.expand('$PYTHONPATH'),
        },
        diagnosticSeverityOverrides = {
          reportMissingImports = "none",
          reportGeneralTypeIssues = "warning"
        }
      }
    }
  }
})

-- Lua LSP 設定
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.git', '.luarc.json', '.luacheckrc' },
  single_file_support = true,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = { 'vim' }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
      telemetry = {
        enable = false
      }
    }
  }
})

-- 啟用 LSP 伺服器
vim.lsp.enable('pyright')
vim.lsp.enable('lua_ls')
EOF
