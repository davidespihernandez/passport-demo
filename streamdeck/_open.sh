#!/usr/bin/env bash
# Opens a NEW iTerm window running the given shell command (usage: _open.sh "<command>" [keep-shell])
CMD="cd \"\$HOME/Documents/code/passport-demo\" && $1"
[ "${2:-0}" = 1 ] && CMD="$CMD; echo; echo '[done]'; exec \"\$SHELL\" -l"
osascript - "$CMD" <<'OSA'
on run argv
  tell application "iTerm"
    activate
    create window with default profile command ("/bin/bash -lc " & quoted form of (item 1 of argv))
  end tell
end run
OSA
