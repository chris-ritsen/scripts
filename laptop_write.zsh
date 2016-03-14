#!/usr/bin/zsh

function() {

local brightness=$(cat /sys/class/backlight/intel_backlight/brightness)

local touch=$(synclient | grep -i touchpadoff | grep -oe'[0-1]')

while [[ true ]]; do

# TODO: Update saved brightness when changed elsewhere only if non-zero

# TODO: Grab initial backlight value and reset on exit, i.e., `ctrl-c`.

# TODO: Only do this when the screen is the laptop screen.

# TODO: Disable the spell setting when in insert mode; re-enable if previously
# enabled.

local format='#{window_index}#{window_active}#{session_attached}'
local match='111'
local socket='/home/chris/.tmp/tmux/tmux-1000/admin'

local active_window_name=$(xdotool getactivewindow getwindowname 2>/dev/null)
local has_active=$(tmux -S $socket ls -F $format | grep -e $match)
local has_insert=$(vim --servername NOTES --remote-expr 'mode()')
local lid_state=$(cat /proc/acpi/button/lid/LID0/state)

if [[ -z $(echo $lid_state | grep -ie 'open') ]]; then
  sleep 1
fi

synclient TouchPadOff=1

if [[ $has_insert == 'i' && $has_active == $match && $active_window_name == 'notes' ]]; then
  echo 0 > $BL
else
  echo $brightness > $BL
fi

sleep 0.5;

trap "synclient TouchPadOff=$touch; break" 2

done

}

