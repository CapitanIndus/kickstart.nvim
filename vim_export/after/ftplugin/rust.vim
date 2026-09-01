setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab

if exists('b:undo_ftplugin') && !empty(b:undo_ftplugin)
  let b:undo_ftplugin .= ' | setlocal tabstop< shiftwidth< softtabstop< expandtab<'
else
  let b:undo_ftplugin = 'setlocal tabstop< shiftwidth< softtabstop< expandtab<'
endif
