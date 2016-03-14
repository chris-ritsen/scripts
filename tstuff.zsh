#!/usr/bin/zsh

socket='/home/chris/.tmp/tmux/tmux-1000/admin'

format_panes="-F '#{pane_title} #{pane_active}'"
format_sessions="-F '#{session_windows} #{session_name} #{session_grouped} #{session_id} #{session_created} #{session_attached} '"
format_windows="-F '#{alternate_on} #{window_name} #{window_active} #{window_zoomed_flag} #{window_panes} #{window_last_flag} '"
target_session='-t admin@laptop'

sessions=$(tmux -S $socket ls -F '#{session_name}')

for i in $sessions; do
  echo $i $(tmux -S $socket list-sessions -F '#{session_name} #{session_id}' | grep $i)
done;

exit

first="   tmux -S $socket list-sessions $format_sessions"
second="  tmux -S $socket list-panes    $target_session $format_panes"
third="   tmux -S $socket list-windows  $format_windows"

watch -tn1 -tn0.1 "$first; $second; $third"

