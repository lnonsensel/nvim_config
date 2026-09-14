# nvim

Конфиг Neovim на базе [LazyVim](https://github.com/LazyVim/LazyVim).
Основной сценарий — Python с [uv](https://docs.astral.sh/uv/); дополнительно есть
Lua, C/C++, Rust и Swift.

Требует **Neovim 0.12+** (используется `vim.lsp.config` / `vim.lsp.enable`).

---

## Быстрый старт

```bash
git clone git@github.com:lnonsensel/nvim_config.git ~/.config/nvim
nvim   # lazy.nvim сам себя развернёт и поставит плагины
```

### Внешние зависимости

| Что | Зачем | Установка |
| --- | --- | --- |
| `uv` | управление проектами и venv | [astral.sh/uv](https://docs.astral.sh/uv/) |
| `basedpyright` | LSP для Python | `uv tool install basedpyright` |
| `inotify-tools` | см. «Слежение за файлами» ниже | `pacman -S inotify-tools` |
| `node` | нужен части серверов из Mason | mise / системный пакет |
| `ripgrep`, `fd` | поиск и пикеры | `pacman -S ripgrep fd` |
| `debugpy` | отладка Python (**не установлен**) | см. «Отладка» |

`ruff`, `lua-language-server`, `clangd`, `rust-analyzer`, `stylua`, `shfmt`
ставятся через Mason автоматически.

---

## Структура

```
init.lua                              точка входа, тянет config.lazy
lua/config/
  lazy.lua                            бутстрап lazy.nvim
  options.lua                         опции + выбор Python LSP
  keymaps.lua, autocmds.lua           пусто, точки расширения
  remote_clipboard.lua                буфер обмена через OSC 52
lua/plugins/
  lsp.lua                             basedpyright + ruff
  python.lua                          форматирование через ruff
  theme.lua                → symlink в состояние omarchy
  all-themes.lua                      11 колорсхем для переключения
  omarchy-theme-hotreload.lua         подхват смены темы без рестарта
  sourcekit.lua                       Swift LSP
  noice.lua                           выключен LSP-прогресс в углу
  snacks-animated-scrolling-off.lua   без анимации скролла
  disable-news-alert.lua              без баннера новостей LazyVim
  example.lua                         шаблон из стартера, неактивен
plugin/after/transparency.lua         прозрачный фон
lazyvim.json                          список включённых LazyVim extras
.neoconf.json                         настройка lua_ls под разработку конфига
```

### Включённые extras

`dap.core` · `editor.neo-tree` · `lang.python` · `lang.toml` · `test.core`

Менять через `:LazyExtras`.

---

## Python + uv

Рабочий процесс рассчитан на стандартный layout uv: `pyproject.toml` в корне и
venv в `./.venv`.

```bash
uv init myproject && cd myproject
uv add requests
uv add --dev pytest
nvim .
```

Отдельно указывать интерпретатор не нужно — `.venv` находят сами и
basedpyright, и `neotest-python` (глобит `*/pyvenv.cfg`), и `nvim-dap-python`
(обходит `venv/.venv/env/.env`).

Если `UV_PROJECT_ENVIRONMENT` указывает на venv **вне** проекта,
автоопределение не сработает — выбрать вручную: `<leader>cv`.

### Разделение ролей

| Инструмент | Отвечает за |
| --- | --- |
| `basedpyright` | типы, переходы, hover, автодополнение |
| `ruff` (LSP) | линт |
| `ruff` (CLI, через conform) | форматирование и сортировка импортов |

Чтобы одна проблема не показывалась дважды, у basedpyright выключены
`reportUnusedImport` и `reportUnusedVariable` — их сообщает ruff (F401/F841).
У ruff, в свою очередь, отключён `hoverProvider`, иначе `K` показывал бы
описание правила вместо типа.

Стиль и набор правил задаются не здесь, а в `pyproject.toml` проекта:

```toml
[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]
```

### Форматирование

На сохранении выполняется `ruff check --fix --select=I001` (только сортировка
импортов), затем `ruff format`. Неиспользуемые импорты **не удаляются
автоматически** — они лишь подсвечиваются. Если хочется, чтобы автофиксы ruff
применялись на сохранении, добавьте `"ruff_fix"` первым в
`lua/plugins/python.lua`.

### Тесты

`neotest` с адаптером `neotest-python`; раннер выбирается сам (pytest, если он
есть в venv).

| Клавиша | Действие |
| --- | --- |
| `<leader>tr` | запустить ближайший тест |
| `<leader>tt` | запустить файл |
| `<leader>tT` | запустить все файлы |
| `<leader>ts` | панель со сводкой |
| `<leader>tO` | панель вывода |
| `<leader>tw` | watch-режим |

### Отладка

⚠️ **Требует установки `debugpy`** — сейчас его нет, без него `<leader>dc` на
Python-файле не заработает. Поставить одним из способов:

```bash
uv add --dev debugpy      # в конкретный проект
# либо глобально, через Mason:  :MasonInstall debugpy
```

| Клавиша | Действие |
| --- | --- |
| `<leader>db` | точка останова |
| `<leader>dc` | запустить / продолжить |
| `<leader>di` / `<leader>dO` / `<leader>do` | step into / over / out |
| `<leader>dr` | REPL |
| `<leader>de` | вычислить выражение |
| `<leader>dPt` / `<leader>dPc` | отладить тест-метод / тест-класс |

---

## Темы и интеграция с omarchy

`lua/plugins/theme.lua` — **симлинк** на
`~/.local/state/omarchy/current/theme/neovim.lua`. Когда omarchy переключает
тему, меняется цель симлинка.

`omarchy-theme-hotreload.lua` слушает `User LazyReload`, перечитывает
`plugins/theme.lua`, сбрасывает загруженные модули колорсхемы и применяет новую
— без перезапуска Neovim. В `all-themes.lua` перечислены 11 колорсхем, которые
ставятся, но не активируются, чтобы любая из них была доступна мгновенно.

### Прозрачный фон

`plugin/after/transparency.lua` снимает `bg` у ~40 highlight-групп.

Важно, что это повешено на автокоманду `ColorScheme`, а не выполняется один раз
при старте: любой `:colorscheme` переопределяет группы целиком и вернул бы фон.
Группа автокоманд создаётся с `clear = true`, поэтому повторный `:source` файла
не плодит дубликаты.

Добавить группу — просто дописать её имя в список `groups`.

---

## Буфер обмена

`lua/config/remote_clipboard.lua` отправляет каждый `y` через **OSC 52**. Внутри
tmux это превращается в tmux-буфер, который рассылается всем подключённым
клиентам — локальным и по SSH. Вставка предпочитает локальный буфер Wayland,
если он доступен, так что скопированное в других приложениях остаётся
вставляемым; без дисплея вставка делается OSC 52-запросом, на который отвечает
tmux или терминал.

Благодаря этому копирование работает одинаково в локальном окне и в сессии
через SSH.

---

## Неочевидные решения

Несколько мест, которые выглядят странно, но сделаны намеренно — чтобы их не
«починили» обратно.

### `mason = false` у basedpyright

basedpyright ставится через `uv tool install`, а не через Mason. Без
`mason = false` LazyVim не вызывает `vim.lsp.enable` сам, а передаёт это
`mason-lspconfig.automatic_enable`
(`lazyvim/plugins/lsp/init.lua:257`), который поднимает только пакеты,
установленные самим Mason. Сервер при этом **молча не стартует** — ошибки не
будет, просто не будет типов.

Обновляется через `uv tool upgrade basedpyright`.

### `typeCheckingMode = "standard"`

По умолчанию basedpyright работает в режиме `recommended`, а он на обычном
нетипизированном коде выдаёт предупреждение почти на каждый параметр без
аннотации («Type of parameter is unknown», «Return type is Any»). На шести
строках кода это шесть warning'ов. `standard` соответствует поведению обычного
pyright; в этом режиме на том же файле остаётся только настоящая ошибка типов.

### Слежение за файлами (`didChangeWatchedFiles`)

Neovim на Linux по умолчанию **не** анонсирует эту capability — см.
`runtime/lua/vim/lsp/protocol.lua`, где она включается только при
`sysname == 'Darwin' or 'Windows_NT'`. Из-за этого basedpyright не узнаёт о
новых файлах и новых зависимостях и требует `:LspRestart`. В `lsp.lua` она
включена принудительно через псевдо-сервер `["*"]`, который LazyVim
разворачивает в `vim.lsp.config("*", …)`.

Для этого нужен системный `inotify-tools`. Без него Neovim откатывается на
бэкенд `vim._watch.watchdirs`, который сообщает о создании файла как
`Changed(2)` вместо `Created(1)`, а pyright сбрасывает кэш резолва импортов
только на `Created`.

### `root_dir` отсекает `site-packages` и `.venv`

Иначе при переходе «к определению» в код зависимости LSP поднимает ещё один
инстанс сервера с корнем внутри venv.

---

## Обслуживание

```vim
:Lazy         " плагины
:LazyExtras   " включить/выключить extras LazyVim
:Mason        " внешние бинарники
:checkhealth  " диагностика
```

```bash
uv tool upgrade basedpyright
```

Версии плагинов зафиксированы в `lazy-lock.json`; после `:Lazy update` его
стоит коммитить.
