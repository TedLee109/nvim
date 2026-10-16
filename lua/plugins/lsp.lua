return {
  -- 1. 徹底停用 Mason 及其自動下載插件
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  -- 2. 直接使用 nvim-lspconfig 讀取系統 / Pixi 的 LSP 執行檔
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Clangd
      opts.servers.clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--query-driver=/usr/local/cuda-11.8/bin/nvcc",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      }

      -- Lua LS
      opts.servers.lua_ls = {}
    end,
  },
}