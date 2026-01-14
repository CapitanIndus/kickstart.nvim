return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    strategies = {
      chat = { adapter = 'ollamac' },
      inline = { adapter = 'ollamac' },
    },
    adapters = {
      http = {
        ollamac = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'deepseek-coder:33b',
              },
            },
            env = {
              url = 'http://julians-pc.frank:11434',
            },
          })
        end,
      },
    },
  },
}
