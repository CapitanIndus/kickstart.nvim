return {
  {
    'NMAC427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup {
        filetype_exclude = {
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
        },
      }
    end,
  },
  { import = 'plugins.whichkey' },
  { import = 'plugins.telescope' },
  { import = 'plugins.gitsigns' },
  { import = 'plugins.lsp' },
  { import = 'plugins.conform' },
  { import = 'plugins.code_companion' },
  { import = 'plugins.blink' },
  { import = 'plugins.colorscheme_tokyonight' },
  { import = 'plugins.colorscheme_nordic' },
  { import = 'plugins.todo_comments' },
  { import = 'plugins.treesitter' },
  { import = 'kickstart.plugins.neo-tree' },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },
  {
    'mfussenegger/nvim-jdtls',
  },
}
