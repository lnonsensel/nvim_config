return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          capabilities = {
            workspace = {
              -- Neovim на Linux по умолчанию НЕ анонсирует эту capability
              -- (см. runtime/lua/vim/lsp/protocol.lua, sysname == 'Darwin' or 'Windows_NT'),
              -- поэтому basedpyright не узнаёт о новых файлах и новых зависимостях
              -- и требует :LspRestart. Включаем принудительно.
              --
              -- ВАЖНО: требуется системный пакет inotify-tools. Без него nvim
              -- откатывается на бэкенд vim._watch.watchdirs, который сообщает о
              -- создании файла как Changed(2) вместо Created(1), а pyright
              -- сбрасывает кэш резолва импортов только на Created.
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
        pyright = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname:match("site%-packages") or fname:match("/%.venv/") then
              return
            end
            on_dir(vim.fs.root(bufnr, { "pyproject.toml", "setup.py", ".git" }))
          end,
          settings = {
            python = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                },
              },
            },
          },
        },
        ruff = {
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname:match("site%-packages") or fname:match("/%.venv/") then
              return
            end
            on_dir(vim.fs.root(bufnr, { "pyproject.toml", ".git" }))
          end,
        },
      },
    },
  },
}
