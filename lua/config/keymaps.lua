-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "<leader>gi", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/implementation" }) > 0 then
    vim.lsp.buf.implementation()
  elseif #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" }) > 0 then
    vim.lsp.buf.definition()
  else
    vim.notify("目前沒有支援跳到實作或定義的 LSP，請用 :LspInfo 檢查。", vim.log.levels.INFO)
  end
end, { desc = "Go to implementation (or definition)" })
vim.keymap.set("n", "<leader>K", vim.lsp.buf.hover, { desc = "Hover documentation" })
