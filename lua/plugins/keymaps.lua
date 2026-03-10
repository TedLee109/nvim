-- telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

-- file_tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

-- comment_toggle
vim.keymap.set("n", "<leader>/", ":CommentToggle<cr>")

vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>n", ":bn<cr>")
return {}
