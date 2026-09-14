return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Без этого форматирование Python шло через LSP (ruff server), и
        -- сортировка импортов не выполнялась вовсе.
        --
        -- ruff_organize_imports = `ruff check --fix --select=I001`, т.е. только
        -- сортировка; неиспользуемые импорты (F401) он НЕ трогает — их показывает
        -- диагностика, удаление остаётся ручным. Если захочется, чтобы автофиксы
        -- ruff применялись на сохранении, добавьте сюда "ruff_fix" первым.
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },

  -- Отдельная настройка интерпретатора под uv не нужна, проверено по исходникам:
  --   * neotest-python (base.lua:41) ищет */pyvenv.cfg и .*/pyvenv.cfg в корне
  --     проекта, т.е. находит .venv раньше, чем доходит до ветки с uv.lock;
  --   * nvim-dap-python (dap-python.lua:118) обходит корни и проверяет
  --     venv/.venv/env/.env;
  --   * basedpyright подхватывает ./.venv сам.
  -- Всё это работает на стандартном layout uv. Если UV_PROJECT_ENVIRONMENT
  -- указывает venv вне проекта, венв придётся выбрать руками: <leader>cv.
}
