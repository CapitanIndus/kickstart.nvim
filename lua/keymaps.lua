-- Clear search highlights on ESC
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic quickfix
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Terminal escape
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Better split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

--Personal Mappings
vim.keymap.set({ 'n', 'x', 'o' }, 'z', 'n', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'Z', 'N', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'n', 'h', { noremap = true, silent = true, desc = 'Left' })
vim.keymap.set({ 'n', 'x', 'o' }, 'r', 'j', { noremap = true, silent = true, desc = 'Down' })
vim.keymap.set({ 'n', 'x', 'o' }, 's', 'l', { noremap = true, silent = true, desc = 'Right' })
vim.keymap.set({ 'n', 'x', 'o' }, 'l', 'k', { noremap = true, silent = true, desc = 'Up' })
--Disable hjkl
vim.keymap.set({ 'n', 'x', 'o' }, 'h', '<Nop>', { noremap = true, silent = true, desc = 'which_key_ignore' })
vim.keymap.set({ 'n', 'x', 'o' }, 'j', '<Nop>', { noremap = true, silent = true, desc = 'which_key_ignore' })
vim.keymap.set({ 'n', 'x', 'o' }, 'k', '<Nop>', { noremap = true, silent = true, desc = 'which_key_ignore' })

-- Undo auf ä redo auf Ä
vim.keymap.set('n', 'ä', 'u', { noremap = true, silent = true })
vim.keymap.set('n', 'Ä', '<C-r>', { noremap = true, silent = true })

-- Insert auf u / U
vim.keymap.set('n', 'u', 'i', { noremap = true, silent = true })
vim.keymap.set('n', 'U', 'I', { noremap = true, silent = true })

-- Wortbewegungen
vim.keymap.set({ 'n', 'x', 'o' }, 'e', 'w', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', 'b', { noremap = true, silent = true })

-- Change Window
vim.keymap.set({ 'n' }, '<leader>ws', '<cmd>wincmd l<CR>', { noremap = true, silent = true, desc = 'Go to right window' })
vim.keymap.set({ 'n' }, '<leader>wl', '<cmd>wincmd k<CR>', { noremap = true, silent = true, desc = 'Go to upper window' })
vim.keymap.set({ 'n' }, '<leader>wr', '<cmd>wincmd j<CR>', { noremap = true, silent = true, desc = 'Go to down window' })
vim.keymap.set({ 'n' }, '<leader>wn', '<cmd>wincmd h<CR>', { noremap = true, silent = true, desc = 'Go to left window' })

-- Wortende (nur Normal & Visual, damit Textobjekte bleiben)
vim.keymap.set({ 'n', 'x' }, 'i', 'e', { noremap = true, silent = true })

-- Großbuchstaben (WORD)
vim.keymap.set({ 'n', 'x', 'o' }, 'E', 'W', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', 'B', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'I', 'E', { noremap = true, silent = true })

-- Zeichen-Sprung (bis vor Zeichen)
vim.keymap.set({ 'n', 'x', 'o' }, 'b', 't', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'B', 'T', { noremap = true, silent = true })
