-- Make highlight groups transparent while preserving their other attributes
local function make_transparent(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if ok then
		hl.bg = nil
		vim.api.nvim_set_hl(0, name, hl)
	end
end

local groups = {
	-- transparent background
	"Normal",
	"NormalFloat",
	"FloatBorder",
	"Pmenu",
	"Terminal",
	"EndOfBuffer",
	"FoldColumn",
	"Folded",
	"SignColumn",
	"LineNr",
	"CursorLineNr",
	"NormalNC",
	"WhichKeyFloat",
	"TelescopeBorder",
	"TelescopeNormal",
	"TelescopePromptBorder",
	"TelescopePromptTitle",
	-- neotree
	"NeoTreeNormal",
	"NeoTreeNormalNC",
	"NeoTreeVertSplit",
	"NeoTreeWinSeparator",
	"NeoTreeEndOfBuffer",
	-- nvim-tree
	"NvimTreeNormal",
	"NvimTreeVertSplit",
	"NvimTreeEndOfBuffer",
	-- notify
	"NotifyINFOBody",
	"NotifyERRORBody",
	"NotifyWARNBody",
	"NotifyTRACEBody",
	"NotifyDEBUGBody",
	"NotifyINFOTitle",
	"NotifyERRORTitle",
	"NotifyWARNTitle",
	"NotifyTRACETitle",
	"NotifyDEBUGTitle",
	"NotifyINFOBorder",
	"NotifyERRORBorder",
	"NotifyWARNBorder",
	"NotifyTRACEBorder",
	"NotifyDEBUGBorder",
}

local function apply()
	for _, name in ipairs(groups) do
		make_transparent(name)
	end
end

-- Раньше файл просто выполнял цикл один раз при старте, поэтому любая смена
-- colorscheme (в т.ч. hot-reload темы omarchy) возвращала фон: colorscheme
-- переопределяет highlight-группы целиком. Вешаемся на ColorScheme, чтобы
-- прозрачность восстанавливалась сама.
--
-- augroup с clear=true делает повторный :source этого файла идемпотентным.
vim.api.nvim_create_augroup("UserTransparency", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = "UserTransparency",
	callback = apply,
})

-- На случай, если colorscheme уже применён к моменту загрузки этого файла.
apply()
