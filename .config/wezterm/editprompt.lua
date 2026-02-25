-- editprompt.lua
-- editprompt関連のキーバインディング設定

local wezterm = require 'wezterm'
local act = wezterm.action

local module = {}

-- editpromptのキーバインディングを返す関数
function module.setup()
  return {
    {
      key = "q",
      mods = "OPT",
      action = wezterm.action_callback(function(window, pane)
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
      end),
    },
  }
end

return module
