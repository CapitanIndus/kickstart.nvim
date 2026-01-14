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
vim.keymap.set({ 'n', 'x' }, 'z', 'n', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'Z', 'N', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'n', 'h', opts)
vim.keymap.set({ 'n', 'x', 'o' }, 'r', 'j', opts)
vim.keymap.set({ 'n', 'x', 'o' }, 's', 'l', opts)
vim.keymap.set({ 'n', 'x', 'o' }, 'l', 'k', opts)

-- Undo auf ä redo auf Ä
vim.keymap.set('n', 'ä', 'u', { noremap = true, silent = true })
vim.keymap.set('n', 'Ä', '<C-r>', { noremap = true, silent = true })

-- Insert auf u / U
vim.keymap.set('n', 'u', 'i', { noremap = true, silent = true })
vim.keymap.set('n', 'U', 'I', { noremap = true, silent = true })

-- Wortbewegungen
vim.keymap.set({ 'n', 'x', 'o' }, 'e', 'w', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', 'b', { noremap = true, silent = true })

-- Wortende (nur Normal & Visual, damit Textobjekte bleiben)
vim.keymap.set({ 'n', 'x' }, 'i', 'e', { noremap = true, silent = true })

-- Großbuchstaben (WORD)
vim.keymap.set({ 'n', 'x', 'o' }, 'E', 'W', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', 'B', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'I', 'E', { noremap = true, silent = true })

-- Zeichen-Sprung (bis vor Zeichen)
vim.keymap.set({ 'n', 'x', 'o' }, 'b', 't', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'B', 'T', { noremap = true, silent = true })
