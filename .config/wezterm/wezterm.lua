-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.automatically_reload_config = false

-- For example, changing the color scheme:
config.color_scheme = 'AdventureTime'
wezterm.on('window-config-reloaded', function(window, pane)
    wezterm.log_info 'the config was reloaded for this window!'
  end)

-- update
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

-- bell
config.audible_bell = "Disabled"

-- scroll backline
config.scrollback_lines = 3500

-- macOS Left and Right Option Key
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.use_dead_keys = false

-- ime
config.use_ime = true

-- exit
config.exit_behavior = 'CloseOnCleanExit'

-- This is where you actually apply your config choices
-- config.color_scheme = "Dracula (Official)"
-- config.color_scheme = "Dracula (Gogh)"
config.color_scheme = "Dracula+"
config.char_select_bg_color = "#282A36"
config.char_select_fg_color = "#F8F8F2"
config.window_background_opacity = 0.3
config.macos_window_background_blur = 20
config.window_frame = {
    inactive_titlebar_bg = "#44475A",

    active_titlebar_bg = "#BD93F9",
    inactive_titlebar_fg = "#44475A",
    active_titlebar_fg = "#F8F8F2",
    inactive_titlebar_border_bottom = "#282A36",
    active_titlebar_border_bottom = "#282A36",
    button_fg = "#44475A",
    button_bg = "#282A36",
    button_hover_fg = "#F8F8F2",
    button_hover_bg = "#282A36",
   }
   config.window_padding = {
    left = 5,
    right = 5,
    top = 10,
    bottom = 5,
   }
config.window_background_gradient = {
        -- Can be "Vertical" or "Horizontal".  Specifies the direction
        -- in which the color gradient varies.  The default is "Horizontal",
        -- with the gradient going from left-to-right.
        -- Linear and Radial gradients are also supported; see the other
        -- examples below
        -- orientation = "Vertical",
        orientation = { Linear = { angle = -50.0 } },

        -- Specifies the set of colors that are interpolated in the gradient.
        -- Accepts CSS style color specs, from named colors, through rgb
        -- strings and more
        -- colors = {
        --      "#0f0c29",
        --      "#302b63",
        --      "#24243e",
        --},
        colors = {
                "#0f0c29",
                "#282a36",
                "#343746",
                "#3a3f52",
                "#343746",
                "#282a36",
        },
        -- colors = { "Inferno" },

        -- Instead of specifying `colors`, you can use one of a number of
        -- predefined, preset gradients.
        -- A list of presets is shown in a section below.
        -- preset = "Warm",

        -- Specifies the interpolation style to be used.
        -- "Linear", "Basis" and "CatmullRom" as supported.
        -- The default is "Linear".
        interpolation = "Linear",

        -- How the colors are blended in the gradient.
        -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
        -- The default is "Rgb".
        blend = "Rgb",

        -- To avoid vertical color banding for horizontal gradients, the
        -- gradient position is randomly shifted by up to the `noise` value
        -- for each pixel.
        -- Smaller values, or 0, will make bands more prominent.
        -- The default value is 64 which gives decent looking results
        -- on a retina macbook pro display.
        noise = 64,

        -- By default, the gradient smoothly transitions between the colors.
        -- You can adjust the sharpness by specifying the segment_size and
        -- segment_smoothness parameters.
        -- segment_size configures how many segments are present.
        -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
        -- 1.0 is a soft edge.

        segment_size = 11,
        segment_smoothness = 1.0,
}
-- config.font = wezterm.font("Moralerspace Argon")
config.font = wezterm.font("JetBrains Mono")
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.text_background_opacity = 0.95
config.font_size = 16
config.cell_width = 1.0
config.line_height = 1.0
config.use_cap_height_to_scale_fallback_fonts = true

-- keybinds
-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true
-- `keybinds.lua`を読み込み
local keybind = require 'keybinds'
-- keybindの設定
config.keys = keybind.keys
config.key_tables = keybind.key_tables
-- Leaderキーの設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }

-- editprompt機能（ALT+q / OPT+q）
wezterm.on('user-defined-0', function(window, pane)
  -- 送信先（上のClaude Codeペイン）のIDを先に保持
  local target = tostring(pane:pane_id())

  -- 下分割し、その新ペイン内で editprompt を起動
  -- 終了後に "自分自身のペイン" を kill して自動クローズ
  window:perform_action(
    act.SplitPane({
      direction = "Down",
      size = { Cells = 10 },
      command = {
        args = {
          "bash", "-lc",
          string.format(
            -- エディタは nvim / vim / "code --wait" など好みでOK
            -- exitで確実にシェルごと終了させる
            -- PATHを明示的に設定してHomebrewのコマンドが使えるようにする
            "export PATH=/opt/homebrew/bin:$PATH; /opt/homebrew/bin/editprompt --editor nvim --always-copy --mux wezterm --target-pane %s; exit",
            target
          )
        }
      },
    }),
    pane
  )
end)

-- タブバーのカスタマイズ（セル単位で正確に幅を制御）
local TAB_PADDING = 2 -- 左右の空白

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_bg = '#44475A'
  local colors = tab.is_active and {bg = '#BD93F9', fg = '#282A36'}
                  or hover and {bg = '#6272A4', fg = '#F8F8F2'}
                  or {bg = '#282A36', fg = '#F8F8F2'}

  -- タブタイトルを取得
  local title = tab.active_pane.title

  -- 内容部分の幅を計算（エッジセルを除く）
  local content_width = math.max(0, max_width - (TAB_PADDING + 2))

  -- タイトルを切り詰め、セル幅を計算してパディング
  title = wezterm.truncate_right(title, content_width)
  local fill = content_width - wezterm.column_width(title)
  local padded = title .. string.rep(' ', math.max(0, fill))

  return {
    {Background = {Color = edge_bg}}, {Text = ' '},
    {Background = {Color = colors.bg}}, {Foreground = {Color = colors.fg}},
    {Text = ' ' .. padded .. ' '},
    {Background = {Color = edge_bg}}, {Text = ' '},
  }
end)

local STATUS_DIR_BG = '#1E1F29'
local STATUS_DIR_FG = '#F8F8F2'
local STATUS_TIME_BG = '#6272A4'
local STATUS_TIME_FG = '#1E1F29'
local STATUS_DIR_MAX_COLS = 26 -- これ以上広げると再描画時に溢れやすくなる

local function make_status_cell(text, fg, bg)
  return {
    {Background = {Color = bg}},
    {Foreground = {Color = fg}},
    {Text = ' ' .. text .. ' '},
  }
end

wezterm.on('update-right-status', function(window, pane)
  local cells = {}

  local cwd = ''
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri and cwd_uri.file_path then
    cwd = cwd_uri.file_path
    local home = os.getenv('HOME') or ''
    if cwd:find(home, 1, true) == 1 then
      cwd = '~' .. cwd:sub(#home + 1)
    end
  end

  if cwd ~= '' then
    local dir = wezterm.truncate_right(cwd, STATUS_DIR_MAX_COLS)
    for _, cell in ipairs(make_status_cell(dir, STATUS_DIR_FG, STATUS_DIR_BG)) do
      table.insert(cells, cell)
    end
  end

  local time = wezterm.strftime('%H:%M:%S')
  for _, cell in ipairs(make_status_cell(time, STATUS_TIME_FG, STATUS_TIME_BG)) do
    table.insert(cells, cell)
  end

  window:set_right_status(wezterm.format(cells))
end)

-- This increases color saturation by 50%
config.foreground_text_hsb = {
 hue = 1.0,
 saturation = 1.0,
 brightness = 1.2,
}
-- and finally, return the configuration to wezterm
return config
