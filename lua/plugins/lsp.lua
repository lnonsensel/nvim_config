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
        basedpyright = {
          -- Ставится через `uv tool install basedpyright`, а не через Mason.
          -- Без mason=false LazyVim передаёт включение сервера в
          -- mason-lspconfig.automatic_enable (lsp/init.lua:257), а тот
          -- поднимает только то, что установлено самим Mason, — и сервер
          -- молча не стартует.
          mason = false,

          -- Не поднимать отдельный инстанс на файлах зависимостей.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname:match("site%-packages") or fname:match("/%.venv/") then
              return
            end
            on_dir(vim.fs.root(bufnr, { "pyproject.toml", "setup.py", ".git" }))
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- basedpyright по умолчанию работает в режиме "recommended":
                -- на обычном нетипизированном коде это даёт warning практически
                -- на каждый параметр без аннотации ("Type of parameter is unknown",
                -- "Return type is Any"). "standard" соответствует поведению
                -- обычного pyright.
                typeCheckingMode = "standard",
                diagnosticSeverityOverrides = {
                  -- неиспользуемые импорты и переменные ловит ruff (F401/F841),
                  -- иначе одна и та же проблема показывается дважды
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
