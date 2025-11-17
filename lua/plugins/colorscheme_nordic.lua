return {
  'CapitanIndus/nordic.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nordic').load()
    vim.api.nvim_set_hl(0, 'cssComment', { fg = '#97b67c', italic = true })
  end,
}

