setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab

if exists('b:undo_ftplugin') && !empty(b:undo_ftplugin)
  let b:undo_ftplugin .= ' | setlocal tabstop< shiftwidth< softtabstop< expandtab<'
else
  let b:undo_ftplugin = 'setlocal tabstop< shiftwidth< softtabstop< expandtab<'
endif
