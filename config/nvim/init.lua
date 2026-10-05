vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.background = "dark"
-- HOTKEYS === === ===

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>f", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal current file in explorer" })

-- PYTHON / SCALA COMPILE HOTKEY
--
   vim.keymap.set("n", "<leader>r", function()
     vim.cmd("write")

     local file = vim.fn.expand("%:p")
     local root
     local command

     if vim.bo.filetype == "scala" or vim.bo.filetype == "sbt" then
       local sbt_root = vim.fs.root(file, { "build.sbt" })
       local is_test = file:match("/test/") or file:match("%.test%.scala$")

       if sbt_root then
         -- sbt project: run the app, or just this suite (class name = file name)
         root = sbt_root
         if is_test then
           local suite = vim.fn.fnamemodify(file, ":t:r")
           command = "sbt " .. vim.fn.shellescape("testOnly *" .. suite)
         else
           command = "sbt run"
         end
       else
         -- no build.sbt: scala-cli compiles and runs the single file
         root = vim.fs.root(file, { "project.scala" }) or vim.fn.getcwd()
         command = "scala-cli " .. (is_test and "test " or "run ") .. vim.fn.shellescape(file)
       end
     else
       root = vim.fs.root(file, { "pyproject.toml" }) or vim.fn.getcwd()

       if file:match("/tests/test_.*%.py$") then
         command = "uv run python -m pytest " .. vim.fn.shellescape(file)
       else
         command = "uv run " .. vim.fn.shellescape(file)
       end
     end

     vim.cmd("!cd " .. vim.fn.shellescape(root) .. " && " .. command)
   end, { desc = "Run current Python/Scala file or test" })
-- === === ===

-- Install lazy.nvim automatically
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- Home Manager links the tracked lockfile into the read-only Nix store.
local lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
if vim.fn.filereadable(lockfile) == 0 then
  vim.fn.writefile(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), lockfile)
end

require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    opts = {
      view = { width = 32 },
      renderer = { group_empty = true },
      filters = { git_ignored = true },
      update_focused_file = { enable = true },
    },
  },
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "medium"
      vim.g.everforest_enable_italic = 1
      vim.cmd.colorscheme("everforest")
    end,
  },
  {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  opts = {
   keymap = {
     preset = "default",
     ["<CR>"] = { "select_and_accept", "fallback" },
   },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

   -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
  },
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "basedpyright", "prismals" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "markdown", "markdown_inline", "prisma", "scala" })

      -- build.sbt has its own filetype but is plain Scala
      vim.treesitter.language.register("scala", "sbt")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "prisma", "scala", "sbt" },
        -- pcall: the parser is compiled async on first launch
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("basedpyright", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      vim.lsp.enable("basedpyright")

      vim.lsp.config("prismals", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
      vim.lsp.enable("prismals")

      -- Metals comes from nix (home.nix), not mason
      vim.lsp.config("metals", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        filetypes = { "scala", "sbt" },
        -- one nested list = equal priority, so the nearest build file wins;
        -- .bsp/.scala-build appear for scala-cli projects (see `scala-cli setup-ide .`)
        root_markers = {
          { "build.sbt", "build.mill", "build.sc", "project.scala", ".scala-build", ".bsp" },
          ".git",
        },
      })
      vim.lsp.enable("metals")
    end,
  },
}, { lockfile = lockfile })
