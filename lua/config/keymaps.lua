-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>K", vim.lsp.buf.hover, { desc = "Hover documentation" })
