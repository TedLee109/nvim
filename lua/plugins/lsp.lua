return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = false,
      })
      require("lspconfig").lua_ls.setup({})
      local conda_prefix = os.getenv("CONDA_PREFIX")
      local python_path = conda_prefix and (conda_prefix .. "/bin/python") or "python"
      print(python_path)
      require("lspconfig").pyright.setup({
        settings = {
          python = {
            pythonPath = python_path,
          },
        },
      })
      require("lspconfig").clangd.setup({
        cmd = {
          "clangd",
          "--background-index",
          "--query-driver=/usr/local/cuda-11.8/bin/nvcc", -- Help clangd find headers
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      })
    end,
  },
}
