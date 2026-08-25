return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      -- отключает всплывающее окно с прогрессом LSP ("⠋/✔ basedpyright"),
      -- которое перекрывало код в правом нижнем углу
      progress = { enabled = false },
    },
  },
}
