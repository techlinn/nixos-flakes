
local M = {}

local cache = vim.fn.expand("~/.cache/pwnbox/theme/")
local palette_path = cache .. "nvim-palette.lua"
-- Colours a theme names for itself rather than let them be derived
-- (key=rrggbb, see theme_colors in pwnbox-theme) plus its border colour. Both
-- files are optional, so every role below falls back to the palette.
local colors_path = cache .. "theme-colors"
local border_path = cache .. "border-override"

local raw_default = {
  bg = "#080808",
  fg = "#cccccc",
  cursor = "#cccccc",
  accent = "#252525",
  color0 = "#171717",
  color1 = "#6b6b6b",
  color2 = "#c4c4c4",
  color3 = "#999999",
  color4 = "#999999",
  color5 = "#717171",
  color6 = "#8a8a8a",
  color7 = "#cccccc",
  color8 = "#353535",
  color9 = "#6b6b6b",
  color10 = "#c4c4c4",
  color11 = "#999999",
  color12 = "#999999",
  color13 = "#717171",
  color14 = "#8a8a8a",
  color15 = "#ffffff",
}

local function hex_to_rgb(hex)
  hex = tostring(hex):gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function mix(a, b, amount)
  local ar, ag, ab = hex_to_rgb(a)
  local br, bg, bb = hex_to_rgb(b)
  return rgb_to_hex(
    math.floor(ar + (br - ar) * amount + 0.5),
    math.floor(ag + (bg - ag) * amount + 0.5),
    math.floor(ab + (bb - ab) * amount + 0.5)
  )
end

local function luminance(hex)
  local r, g, b = hex_to_rgb(hex)
  return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
end

-- Black or white, whichever reads on a filled chip, match or cursor.
local function on_fill(hex)
  return luminance(hex) > 0.45 and "#000000" or "#ffffff"
end

local function build_palette(raw, named)
  named = named or {}
  local bg, fg = raw.bg, raw.fg
  local extreme = luminance(bg) < 0.5 and "#ffffff" or "#000000"
  local shade = raw.color8 or mix(bg, fg, 0.43) -- the neutral the text ladder is spaced on
  local accent = named.border or named.accent_strong or raw.accent or fg
  if math.abs(luminance(accent) - luminance(bg)) < 0.18 then
    accent = mix(accent, fg, 0.6) -- an accent lost in the background is no accent
  end
  local num = raw.color9 or raw.color1 or fg
  local ty = raw.color2 or fg
  local sand = raw.color3 or fg
  -- color0 is the float and menu card, unless it sits nowhere near the background.
  local card = raw.color0 or mix(bg, fg, 0.05)
  if math.abs(luminance(card) - luminance(bg)) > 0.25 then
    card = mix(bg, fg, 0.05)
  end
  local p = {
    bg = bg,
    bg_alt = mix(bg, fg, 0.04),
    card = card,
    card_hi = mix(card, fg, 0.10),
    cursorline = mix(bg, shade, 0.28),
    sel = named.selection or mix(bg, shade, 0.45),
    -- text, dimmest first
    comment = mix(bg, shade, 0.92),
    brace = mix(shade, fg, 0.05),
    punct = mix(shade, fg, 0.09),
    op = mix(shade, fg, 0.31),
    panel = mix(shade, fg, 0.36),
    var = mix(shade, fg, 0.54),
    member = raw.color7 or fg,
    fg = fg,
    bright = mix(fg, extreme, 0.51),
    white = extreme,
    -- the accent and its dimmer steps
    accent = accent,
    accent_hi = raw.cursor or named.link or raw.color12 or accent,
    accent_text = mix(accent, fg, 0.08),
    accent_dim = mix(accent, shade, 0.22),
    link = named.link or raw.color12 or accent,
    -- syntax
    fn = raw.color12 or fg,
    const = raw.color12 or fg,
    type = ty,
    kw = raw.color1 or fg,
    num = num,
    str = mix(fg, num, 0.40),
    sand = sand,
    -- status
    err = named.error or raw.color1 or fg,
    err_text = named.error_text or named.error or raw.color1 or fg,
    warn = named.warning or sand,
    ok = named.success_text or named.success or ty,
    term = {
      raw.color0,
      raw.color1,
      raw.color2,
      raw.color3,
      raw.color4,
      raw.color5,
      raw.color6,
      raw.color7,
      raw.color8,
      raw.color9,
      raw.color10,
      raw.color11,
      raw.color12,
      raw.color13,
      raw.color14,
      raw.color15,
    },
  }
  p.dim = p.comment -- the two names config/plugins.lua still asks for
  p.muted = p.panel
  -- lualine's mode chips: a fill per mode and text that reads on it.
  p.lualine = {
    normal = { bg = p.type, fg = on_fill(p.type) },
    insert = { bg = p.accent, fg = on_fill(p.accent) },
    visual = { bg = p.accent_hi, fg = on_fill(p.accent_hi) },
    replace = { bg = p.err, fg = on_fill(p.err) },
    command = { bg = p.sand, fg = on_fill(p.sand) },
    terminal = { bg = p.str, fg = on_fill(p.str) },
    b = p.panel,
    b_bg = p.bg,
    c = p.var,
  }
  return p
end

local function read_raw()
  local raw = vim.deepcopy(raw_default)
  local chunk = loadfile(palette_path)
  if chunk then
    local ok, generated = pcall(chunk)
    if ok and type(generated) == "table" then
      for k, v in pairs(generated) do
        if type(v) == "string" then
          raw[k] = v
        end
      end
    end
  end
  return raw
end

local function read_named()
  local named = {}
  local function take(key, text)
    local hex = tostring(text or ""):match("^%s*#?(%x%x%x%x%x%x)%s*$")
    if hex then
      named[key] = "#" .. hex:lower()
    end
  end
  if vim.fn.filereadable(colors_path) == 1 then
    for _, line in ipairs(vim.fn.readfile(colors_path)) do
      local key, value = line:match("^%s*([%w_]+)%s*=%s*(%S+)")
      if key then
        take(key, value)
      end
    end
  end
  if vim.fn.filereadable(border_path) == 1 then
    take("border", vim.fn.readfile(border_path)[1])
  end
  return named
end

M.palette = build_palette(raw_default, {})

function M.load()
  local fresh = build_palette(read_raw(), read_named())
  for k, v in pairs(fresh) do
    M.palette[k] = v
  end
  return M.palette
end

M._reload_hooks = {}

function M.on_reload(fn)
  table.insert(M._reload_hooks, fn)
end

local watching = false
function M.watch()
  if watching then
    return
  end
  watching = true
  local uv = vim.uv or vim.loop
  local function signature()
    local parts = {}
    for _, path in ipairs({ palette_path, colors_path, border_path }) do
      if vim.fn.filereadable(path) == 1 then
        table.insert(parts, table.concat(vim.fn.readfile(path), "\n"))
      end
    end
    return table.concat(parts, "\n")
  end
  local last = signature()
  local timer = uv.new_timer()
  timer:start(
    0,
    1500,
    vim.schedule_wrap(function()
      local sig = signature()
      if sig ~= last then
        last = sig
        M.setup()
        for _, fn in ipairs(M._reload_hooks) do
          pcall(fn, M.palette)
        end
        if vim.api.nvim_get_mode().mode ~= "c" then
          vim.cmd("redraw!")
        end
      end
    end)
  )
  M._timer = timer
end

function M.setup()
  M.load()
  local p = M.palette
  local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.background = luminance(p.bg) < 0.5 and "dark" or "light"
  vim.g.colors_name = "pwnbox"

  hl("Normal", { fg = p.fg, bg = p.bg })
  hl("NormalNC", { fg = p.fg, bg = p.bg })
  hl("NormalFloat", { fg = p.fg, bg = p.card })
  hl("FloatBorder", { fg = p.accent, bg = p.card })
  hl("FloatTitle", { fg = p.accent, bg = p.card, bold = true })
  hl("FloatShadow", { bg = p.bg })
  hl("FloatShadowThrough", { bg = p.bg })
  hl("ColorColumn", { bg = p.cursorline })
  hl("Conceal", { fg = p.comment })
  hl("Cursor", { fg = on_fill(p.accent_hi), bg = p.accent_hi })
  hl("lCursor", { fg = on_fill(p.accent_hi), bg = p.accent_hi })
  hl("CursorIM", { fg = on_fill(p.accent_hi), bg = p.accent_hi })
  hl("TermCursor", { fg = on_fill(p.accent_hi), bg = p.accent_hi })
  hl("TermCursorNC", { fg = p.bg, bg = p.comment })
  hl("CursorColumn", { bg = p.cursorline })
  hl("CursorLine", { bg = p.cursorline })
  hl("CursorLineNr", { fg = p.accent_text, bold = true })
  hl("LineNr", { fg = p.comment })
  hl("LineNrAbove", { fg = p.comment })
  hl("LineNrBelow", { fg = p.comment })
  hl("SignColumn", { fg = p.comment, bg = p.bg })
  hl("FoldColumn", { fg = p.comment, bg = p.bg })
  hl("Folded", { fg = p.panel, bg = p.card })
  hl("EndOfBuffer", { fg = p.bg, bg = p.bg })
  hl("NonText", { fg = p.sel })
  hl("Whitespace", { fg = p.sel })
  hl("SpecialKey", { fg = p.comment })
  hl("MatchParen", { fg = p.accent_hi, bold = true, underline = true })
  hl("Directory", { fg = p.accent, bold = true })
  hl("Title", { fg = p.accent, bold = true })
  hl("ErrorMsg", { fg = p.err, bold = true })
  hl("WarningMsg", { fg = p.warn })
  hl("ModeMsg", { fg = p.accent_text, bold = true })
  hl("MoreMsg", { fg = p.const })
  hl("Question", { fg = p.const })
  hl("MsgArea", { fg = p.fg, bg = p.bg })
  hl("MsgSeparator", { fg = p.sel, bg = p.bg })
  hl("WinBar", { fg = p.fg, bg = p.bg, bold = true })
  hl("WinBarNC", { fg = p.comment, bg = p.bg })
  hl("WinSeparator", { fg = p.comment, bg = p.bg })
  hl("VertSplit", { fg = p.comment, bg = p.bg })

  hl("Visual", { bg = p.sel })
  hl("VisualNOS", { bg = p.sel })
  hl("Search", { fg = on_fill(p.type), bg = p.type })
  hl("IncSearch", { fg = on_fill(p.accent), bg = p.accent, bold = true })
  hl("CurSearch", { fg = on_fill(p.accent), bg = p.accent, bold = true })
  hl("Substitute", { fg = on_fill(p.sand), bg = p.sand })

  hl("Pmenu", { fg = p.fg, bg = p.card })
  hl("PmenuSel", { fg = p.fg, bg = p.card_hi, bold = true })
  hl("PmenuKind", { fg = p.str, bg = p.card })
  hl("PmenuKindSel", { fg = p.str, bg = p.card_hi })
  hl("PmenuExtra", { fg = p.comment, bg = p.card })
  hl("PmenuExtraSel", { fg = p.panel, bg = p.card_hi })
  hl("PmenuSbar", { bg = p.sel })
  hl("PmenuThumb", { bg = p.comment })
  hl("WildMenu", { fg = on_fill(p.accent), bg = p.accent })

  hl("StatusLine", { fg = p.var, bg = p.bg })
  hl("StatusLineNC", { fg = p.comment, bg = p.bg })
  hl("TabLine", { fg = p.comment, bg = p.bg })
  hl("TabLineFill", { fg = p.comment, bg = p.bg })
  hl("TabLineSel", { fg = p.accent_text, bg = p.bg, bold = true })

  hl("Comment", { fg = p.comment, italic = true })
  hl("Constant", { fg = p.const })
  hl("String", { fg = p.str })
  hl("Character", { fg = p.str })
  hl("Number", { fg = p.num })
  hl("Float", { fg = p.num })
  hl("Boolean", { fg = p.num })
  hl("Identifier", { fg = p.var })
  hl("Function", { fg = p.fn })
  hl("Statement", { fg = p.kw })
  hl("Conditional", { fg = p.kw })
  hl("Repeat", { fg = p.kw })
  hl("Label", { fg = p.kw })
  hl("Operator", { fg = p.op })
  hl("Keyword", { fg = p.kw })
  hl("Exception", { fg = p.kw })
  hl("PreProc", { fg = p.const })
  hl("Include", { fg = p.kw })
  hl("Define", { fg = p.const })
  hl("Macro", { fg = p.const })
  hl("PreCondit", { fg = p.const })
  hl("Type", { fg = p.type })
  hl("StorageClass", { fg = p.kw, italic = true })
  hl("Structure", { fg = p.type })
  hl("Typedef", { fg = p.type })
  hl("Special", { fg = p.str })
  hl("SpecialChar", { fg = p.kw })
  hl("Tag", { fg = p.accent })
  hl("Delimiter", { fg = p.punct })
  hl("SpecialComment", { fg = p.comment, italic = true })
  hl("Debug", { fg = p.const })
  hl("Underlined", { fg = p.link, underline = true })
  hl("Ignore", { fg = p.comment })
  hl("Error", { fg = p.err, bold = true })
  hl("Todo", { fg = on_fill(p.sand), bg = p.sand, bold = true })

  hl("DiagnosticError", { fg = p.err, bold = true })
  hl("DiagnosticWarn", { fg = p.warn })
  hl("DiagnosticInfo", { fg = p.str })
  hl("DiagnosticHint", { fg = p.comment })
  hl("DiagnosticOk", { fg = p.ok })
  hl("DiagnosticVirtualTextError", { fg = p.err_text, italic = true })
  hl("DiagnosticVirtualTextWarn", { fg = p.warn, italic = true })
  hl("DiagnosticVirtualTextInfo", { fg = p.str, italic = true })
  hl("DiagnosticVirtualTextHint", { fg = p.comment, italic = true })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = p.err })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.warn })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.str })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = p.comment })
  hl("DiagnosticFloatingError", { fg = p.err_text })
  hl("DiagnosticFloatingWarn", { fg = p.warn })
  hl("DiagnosticFloatingInfo", { fg = p.str })
  hl("DiagnosticFloatingHint", { fg = p.comment })

  hl("DiffAdd", { bg = mix(p.bg, p.ok, 0.12) })
  hl("DiffChange", { bg = mix(p.bg, p.warn, 0.12) })
  hl("DiffDelete", { fg = p.err, bg = mix(p.bg, p.err, 0.12) })
  hl("DiffText", { bg = mix(p.bg, p.accent, 0.22), bold = true })
  hl("Added", { fg = p.ok })
  hl("Changed", { fg = p.warn })
  hl("Removed", { fg = p.err })

  local links = {
    ["@comment"] = "Comment",
    ["@error"] = "Error",
    ["@none"] = "Normal",
    ["@preproc"] = "PreProc",
    ["@define"] = "Define",
    ["@operator"] = "Operator",
    ["@punctuation"] = "Delimiter",
    ["@punctuation.delimiter"] = "Delimiter",
    ["@punctuation.bracket"] = { fg = p.brace },
    ["@punctuation.special"] = { fg = p.op },
    ["@string"] = "String",
    ["@string.regex"] = "SpecialChar",
    ["@string.escape"] = "SpecialChar",
    ["@string.special"] = "SpecialChar",
    ["@character"] = "Character",
    ["@character.special"] = "SpecialChar",
    ["@boolean"] = "Boolean",
    ["@number"] = "Number",
    ["@number.float"] = "Float",
    ["@float"] = "Float",
    ["@function"] = "Function",
    ["@function.builtin"] = "Function",
    ["@function.call"] = "Function",
    ["@function.macro"] = "Macro",
    ["@function.method"] = "Function",
    ["@function.method.call"] = "Function",
    ["@method"] = "Function",
    ["@method.call"] = "Function",
    ["@constructor"] = "Type",
    ["@parameter"] = { fg = p.member },
    ["@keyword"] = "Keyword",
    ["@keyword.function"] = { fg = p.kw, italic = true },
    ["@keyword.operator"] = "Operator",
    ["@keyword.return"] = { fg = p.kw, italic = true },
    ["@keyword.storage"] = { fg = p.kw, italic = true },
    ["@keyword.modifier"] = { fg = p.kw, italic = true },
    ["@keyword.conditional"] = "Conditional",
    ["@keyword.repeat"] = "Repeat",
    ["@keyword.exception"] = "Exception",
    ["@keyword.import"] = "Include",
    ["@conditional"] = "Conditional",
    ["@repeat"] = "Repeat",
    ["@debug"] = "Debug",
    ["@label"] = "Label",
    ["@include"] = "Include",
    ["@exception"] = "Exception",
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@type.definition"] = "Typedef",
    ["@type.qualifier"] = { fg = p.kw, italic = true },
    ["@storageclass"] = "StorageClass",
    ["@attribute"] = "PreProc",
    ["@field"] = { fg = p.member },
    ["@property"] = { fg = p.member },
    ["@variable"] = "Identifier",
    ["@variable.builtin"] = "Keyword",
    ["@variable.parameter"] = { fg = p.member },
    ["@variable.member"] = { fg = p.member },
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",
    ["@constant.macro"] = "Macro",
    ["@module"] = "Identifier",
    ["@namespace"] = "Identifier",
    ["@symbol"] = "Identifier",
    ["@text"] = "Normal",
    ["@text.title"] = "Title",
    ["@text.literal"] = "String",
    ["@text.uri"] = "Underlined",
    ["@text.underline"] = "Underlined",
    ["@text.todo"] = "Todo",
    ["@text.note"] = "Special",
    ["@text.warning"] = "WarningMsg",
    ["@text.danger"] = "ErrorMsg",
    ["@text.diff.add"] = "DiffAdd",
    ["@text.diff.delete"] = "DiffDelete",
    ["@text.reference"] = "Identifier",
    ["@text.emphasis"] = { italic = true },
    ["@text.strong"] = { bold = true },
    ["@tag"] = "Tag",
    ["@tag.attribute"] = "PreProc",
    ["@tag.delimiter"] = { fg = p.brace },
    ["@markup"] = "Normal",
    ["@markup.strong"] = { bold = true },
    ["@markup.emphasis"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = "Title",
    ["@markup.raw"] = "String",
    ["@markup.link"] = "Underlined",
    ["@markup.link.url"] = { fg = p.member, underline = true },
    ["@markup.list"] = "Special",
    ["@lsp.type.macro"] = "Macro",
    ["@lsp.type.lifetime"] = { fg = p.kw, italic = true },
    ["@lsp.typemod.keyword.controlFlow"] = "Keyword",
    ["@lsp.typemod.variable.mutable"] = { fg = p.var, underline = false },
  }
  for group, target in pairs(links) do
    if type(target) == "table" then
      hl(group, target)
    else
      hl(group, { link = target })
    end
  end

  hl("TreesitterContext", { bg = p.card })
  hl("TreesitterContextLineNumber", { fg = p.comment, bg = p.card })

  hl("LspReferenceText", { bg = p.sel })
  hl("LspReferenceRead", { bg = p.sel })
  hl("LspReferenceWrite", { bg = p.sel, underline = true })
  hl("LspSignatureActiveParameter", { fg = p.accent, bold = true })
  hl("LspCodeLens", { fg = p.comment })

  hl("GitSignsAdd", { fg = p.ok })
  hl("GitSignsChange", { fg = p.warn })
  hl("GitSignsDelete", { fg = p.err })
  hl("GitSignsAddNr", { fg = p.ok })
  hl("GitSignsChangeNr", { fg = p.warn })
  hl("GitSignsDeleteNr", { fg = p.err })
  hl("GitSignsAddLn", { bg = p.bg_alt })
  hl("GitSignsChangeLn", { bg = p.bg_alt })
  hl("GitSignsCurrentLineBlame", { fg = p.comment, italic = true })

  hl("IblIndent", { fg = p.sel })
  hl("IblScope", { fg = p.comment })
  hl("IblWhitespace", { fg = p.sel })

  hl("WhichKey", { fg = p.accent, bold = true })
  hl("WhichKeyGroup", { fg = p.kw })
  hl("WhichKeyDesc", { fg = p.fg })
  hl("WhichKeySeparator", { fg = p.comment })
  hl("WhichKeyFloat", { bg = p.card })
  hl("WhichKeyBorder", { fg = p.accent, bg = p.card })
  hl("WhichKeyValue", { fg = p.comment })

  hl("NotifyBackground", { bg = p.card })
  hl("NotifyERRORBorder", { fg = p.err })
  hl("NotifyWARNBorder", { fg = p.warn })
  hl("NotifyINFOBorder", { fg = p.str })
  hl("NotifyDEBUGBorder", { fg = p.comment })
  hl("NotifyTRACEBorder", { fg = p.comment })
  hl("NotifyERRORIcon", { fg = p.err })
  hl("NotifyWARNIcon", { fg = p.warn })
  hl("NotifyINFOIcon", { fg = p.str })
  hl("NotifyDEBUGIcon", { fg = p.comment })
  hl("NotifyTRACEIcon", { fg = p.comment })
  hl("NotifyERRORTitle", { fg = p.err })
  hl("NotifyWARNTitle", { fg = p.warn })
  hl("NotifyINFOTitle", { fg = p.str })
  hl("NotifyDEBUGTitle", { fg = p.panel })
  hl("NotifyTRACETitle", { fg = p.panel })
  hl("NotifyERRORBody", { fg = p.fg })
  hl("NotifyWARNBody", { fg = p.fg })
  hl("NotifyINFOBody", { fg = p.fg })
  hl("NotifyDEBUGBody", { fg = p.fg })
  hl("NotifyTRACEBody", { fg = p.fg })

  hl("BufferLineFill", { bg = p.bg })
  hl("BufferLineBackground", { fg = p.comment, bg = p.bg })
  hl("BufferLineBufferVisible", { fg = p.panel, bg = p.bg })
  hl("BufferLineBufferSelected", { fg = p.accent_text, bg = p.bg, bold = true })
  hl("BufferLineSeparator", { fg = p.bg, bg = p.bg })
  hl("BufferLineSeparatorVisible", { fg = p.bg, bg = p.bg })
  hl("BufferLineSeparatorSelected", { fg = p.bg, bg = p.bg })
  hl("BufferLineCloseButton", { fg = p.comment, bg = p.bg })
  hl("BufferLineCloseButtonVisible", { fg = p.comment, bg = p.bg })
  hl("BufferLineCloseButtonSelected", { fg = p.accent_text, bg = p.bg })
  hl("BufferLineIndicatorSelected", { fg = p.accent, bg = p.bg })
  hl("BufferLineModified", { fg = p.accent_text, bg = p.bg })
  hl("BufferLineModifiedSelected", { fg = p.accent_text, bg = p.bg })
  hl("BufferLineDiagnostic", { fg = p.comment, bg = p.bg })
  hl("BufferLineError", { fg = p.err, bg = p.bg })
  hl("BufferLineErrorSelected", { fg = p.err, bg = p.bg, bold = true })
  hl("BufferLineWarning", { fg = p.warn, bg = p.bg })
  hl("BufferLineWarningSelected", { fg = p.warn, bg = p.bg, bold = true })

  hl("DevIconDefault", { fg = p.panel })

  hl("NeoTreeNormal", { fg = p.accent_dim, bg = p.bg })
  hl("NeoTreeNormalNC", { fg = p.accent_dim, bg = p.bg })
  hl("NeoTreeRootName", { fg = p.accent, bold = true })
  hl("NeoTreeDirectoryName", { fg = p.accent_dim })
  hl("NeoTreeDirectoryIcon", { fg = p.accent })
  hl("NeoTreeFileIcon", { fg = p.accent_dim })
  hl("NeoTreeFileName", { fg = p.accent_dim })
  hl("NeoTreeFileNameOpened", { fg = p.accent_text, bold = true })
  hl("NeoTreeIndentMarker", { fg = p.comment })
  hl("NeoTreeExpander", { fg = p.comment })
  hl("NeoTreeDotfile", { fg = p.comment })
  hl("NeoTreeHiddenByName", { fg = p.comment, italic = true })
  hl("NeoTreeIgnored", { fg = p.comment })
  hl("NeoTreeModified", { fg = p.accent_text })
  hl("NeoTreeGitAdded", { fg = p.ok })
  hl("NeoTreeGitModified", { fg = p.accent_text })
  hl("NeoTreeGitDeleted", { fg = p.err })
  hl("NeoTreeGitRenamed", { fg = p.str })
  hl("NeoTreeGitStaged", { fg = p.ok })
  hl("NeoTreeGitUnstaged", { fg = p.warn })
  hl("NeoTreeGitUntracked", { fg = p.warn, italic = true })
  hl("NeoTreeGitConflict", { fg = p.err, bold = true, italic = true })
  hl("NeoTreeGitIgnored", { fg = p.comment })
  hl("NeoTreeCursorLine", { bg = p.cursorline })
  hl("NeoTreeWinSeparator", { fg = p.comment, bg = p.bg })
  hl("NeoTreeEndOfBuffer", { fg = p.bg, bg = p.bg })
  hl("NeoTreeTitleBar", { fg = p.accent, bg = p.bg, bold = true })

  hl("CmpDocumentation", { fg = p.fg, bg = p.card })
  hl("CmpDocumentationBorder", { fg = p.accent, bg = p.card })
  hl("CmpItemAbbr", { fg = p.fg })
  hl("CmpItemAbbrDeprecated", { fg = p.comment, strikethrough = true })
  hl("CmpItemAbbrMatch", { fg = p.accent, bold = true })
  hl("CmpItemAbbrMatchFuzzy", { fg = p.accent, bold = true })
  hl("CmpItemMenu", { fg = p.comment, italic = true })
  hl("CmpItemKind", { fg = p.str })
  hl("CmpItemKindText", { fg = p.panel })
  hl("CmpItemKindFunction", { fg = p.fn })
  hl("CmpItemKindMethod", { fg = p.fn })
  hl("CmpItemKindVariable", { fg = p.var })
  hl("CmpItemKindKeyword", { fg = p.kw })
  hl("CmpItemKindSnippet", { fg = p.const })
  hl("CmpGhostText", { fg = p.comment, italic = true })

  hl("TelescopeNormal", { fg = p.fg, bg = p.card })
  hl("TelescopeBorder", { fg = p.accent, bg = p.card })
  hl("TelescopeTitle", { fg = p.accent, bg = p.card, bold = true })
  hl("TelescopeSelection", { fg = p.fg, bg = p.card_hi })
  hl("TelescopeMatching", { fg = p.accent, bold = true })
  hl("TelescopePromptPrefix", { fg = p.accent })

  for i, color in ipairs(p.term) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end

  M.watch()
end

return M
