return {
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
    },
  },
}
