#!/usr/bin/zsh

function do_stuff() {

# Local variables {{{

local default_socket='/tmp/tmux-1000/default'
local identify='#{host}:#{session_group}:#{line}:#{session_id}:#{window_id}'

typeset -U servers
typeset -U hosts

servers=()
hosts=()

# }}}

# Inititalise {{{

# {{{

tmux_variables=(

# alternate_on
# alternate_saved_x
# alternate_saved_y
# buffer_sample
# buffer_size
# client_activity
# client_activity_string
# client_created
# client_created_string
# client_height
# client_last_session
# client_pid
# client_prefix
# client_readonly
# client_session
# client_termname
# client_tty
# client_utf8
# client_width
# pane_dead_status
# session_alerts
# window_find_matches

# cursor_flag
# cursor_x
# cursor_y
# history_bytes
# history_limit
# history_size
# host
# host_short
# insert_flag
# keypad_cursor_flag
# keypad_flag
# line
# mouse_any_flag
# mouse_button_flag
# mouse_standard_flag
# mouse_utf8_flag
# pane_active
# pane_bottom
# pane_current_path
# pane_dead
# pane_height
# pane_id
# pane_in_mode
# pane_index
# pane_input_off
# pane_left
# pane_pid
# pane_right
# pane_start_command
# pane_synchronized
# pane_tabs
# pane_title
# pane_top
# pane_tty
# pane_width
# pid
# scroll_region_lower
# scroll_region_upper
# session_activity
# session_height
# session_width
# session_windows
# window_activity
# window_activity_flag
# window_bell_flag
# window_flags
# window_height
# window_last_flag
# window_layout
# window_linked
# window_panes
# window_silence_flag
# window_width
# window_zoomed_flag
# wrap_flag

# session_activity_string
# window_activity_string

# pane_current_command
# session_created
# session_created_string
# session_group
# session_grouped
# session_id
# session_many_attached
# session_name
# window_id
# window_index

session_attached
window_panes
window_active
window_name

)

# }}}

# TODO: Split window and session properties into different redis keys.

# TODO: Should group keys for a single invocation of hmset per key

# TODO: Do it this way instead.  Get the list of sessions, then iterate over 
# those for windows, then panes.  Get variables at whichever level is 
# appropriate.  This would allow for getting a list of panes in a window in a 
# session, then getting the pid of each pane

# TODO: Handle ungrouped sessions

# echo $session_groups
# echo $sessions

servers+=($default_socket)

servers+=($(find $(echo "${HOME}"'/.tmp/tmux/tmux-'"${UID}") -type s))

hosts+=($(hostname))
# hosts+=('laptop')

# }}}

# Loop over hostnames {{{

for host in ${(i)hosts}; do

  # Print hostname {{{

  echo 'host:' $host

  # }}}

  local tmux=/usr/local/bin/tmux

  # Loop over tmux servers {{{

  for socket in ${(i)servers}; do

    # guard {{{

    if [[ ! -S $socket ]]; then
      return
    fi

    # }}}

    # Local variables {{{

    local tmux_options=(

    -2 
    -S $socket

    )

    # guard tmux server exists {{{

    $tmux $tmux_options ls 1>/dev/null 2>/dev/null

    # }}}

    if [[ $? != 0 ]]; then
      continue
    fi

    local has_ungrouped_sessions=false
    local server_pid=$($tmux $tmux_options list-sessions -F "#{pid}" | head -n1)

    typeset -U real_groups
    typeset -U session_groups
    typeset -U ungrouped_sessions

    real_groups=()
    session_groups=()
    ungrouped_sessions=()

    IFS=$'\n' session_groups=($($tmux $tmux_options list-sessions -F "#{session_group}:#{session_id}"))
    IFS=$'\n' sessions=($($tmux $tmux_options list-sessions -F "#{session_id}"))

    # }}}

    # Check for ungrouped sessions {{{

    if [[ $($tmux $tmux_options list-sessions -F "(#{session_group})") =~ '\(\)' ]]; then
      has_ungrouped_sessions=true
    fi

    # }}}

    # Get array of grouped session ids {{{

    for session_group in ${session_groups[@]}; do
      session_group=$(echo $session_group | cut -d':' -f1)

      if [[ $session_group ]]; then
        real_groups+=("$session_group")
        continue
      else
        continue
      fi
    done

    # }}}

    # Initialise ungrouped sessions array {{{

    for session in ${session_groups[@]}; do

      local session_group=$(echo $session | cut -d ':' -f 1)
      local session_id=$(echo $session | cut -d ':' -f 2)

      if [[ $session_group ]]; then
        continue
      fi

      ungrouped_sessions+=($session_id)

    done

    # }}}

    # Print server socket and pid {{{ 

    echo '  ''server:' "$socket $server_pid"
     
    # }}}

    # Loop over grouped sessions {{{

    for session_group in ${real_groups[@]}; do

      # Local variables {{{

      typeset -U temp_windows
      typeset -U windows
      typeset -U sessions_with_groups

      temp_windows=()
      windows=()
      sessions_with_groups=()

      # }}}

      # Intitialise session list {{{

      IFS=$'\n' sessions_with_groups=($($tmux $tmux_options list-sessions -F "#{session_group} #{session_id}"))

      # }}}

      # Print session group {{{

      echo '    ''group:' $session_group

      # }}}

      # Loop over a typical session in the session group {{{

      for session in ${sessions_with_groups[@]}; do
        # echo $'\t\t''session:' $session

        IFS=$'\n' temp_windows=($($tmux $tmux_options list-windows -a -F "#{session_group}:#{window_id}"))

        for window in ${(iu)temp_windows[@]}; do
          local window_id=$(echo $window | cut -d ':' -f 2)
          local window_session_group=$(echo $window | cut -d ':' -f 1)

          if [[ $window_session_group != $session_group ]]; then
            continue
          fi

          # echo $session_group $window_id
          windows+=($session_group:$window_id)
        done

        # TODO: Group windows by session_group, not session_id

      done

      # }}}

      # Loop over windows of grouped sessions {{{

      for window in ${(iu)windows[@]}; do
        local window_session_group=$(echo $window | cut -d ':' -f 1)
        local window_id=$(echo $window | cut -d ':' -f 2)

        if [[ $window_session_group != $session_group ]]; then
          continue
        fi

        local window_name=$($tmux $tmux_options list-panes -t $window_id -F "#{window_name}" | head -n1)

        print '      '"$window_name"':' $window_id

        IFS=$'\n' panes=($($tmux $tmux_options list-panes -t $window_id -F "#{pane_id}:#{pane_pid}"))

        for pane in ${panes[@]}; do

          local pane_command=$($tmux $tmux_options list-panes -t $window_id -F "#{pane_current_command}" | head -n1)
          local pane_id=$(echo $pane | cut -d ':' -f 1)
          local pane_pid=$(echo $pane | cut -d ':' -f 2)

          print '        '"$pane_command"':' $pane_id $pane_pid

        done
      done
      
      # }}}

    done

    # }}}

    # Loop over ungrouped sessions {{{

    for session in ${ungrouped_sessions[@]}; do

      IFS=$'\n' windows=($($tmux $tmux_options list-windows -t $session -F "#{window_id}"))

      local session_name=$($tmux $tmux_options list-panes -t $session -F "#{session_name}" | head -n1)

      # guard {{{

      if [[ -z $session_name ]]; then
        continue
      fi

      # }}}

      echo '    '"$session_name"': '"$session"

      # Loop over windows {{{

      for window_id in ${(iu)windows[@]}; do

        local window_name=$($tmux $tmux_options list-panes -t $window_id -F "#{window_name}" | head -n1)

        print $'      '"$window_name"':' $window_id

        IFS=$'\n' panes=($($tmux $tmux_options list-panes -t $window_id -F "#{pane_id}:#{pane_pid}"))

        # Loop over panes {{{

        for pane in ${panes[@]}; do

          local pane_command=$($tmux $tmux_options list-panes -t $window_id -F "#{pane_current_command}" | head -n1)
          local pane_id=$(echo $pane | cut -d ':' -f 1)
          local pane_pid=$(echo $pane | cut -d ':' -f 2)

          print $'        '"$pane_command"':' $pane_id $pane_pid

        done

        # }}}

      done

      # }}}

    done

    # }}}

    # Buffers {{{ 

    IFS=$'\n' buffers=($($tmux $tmux_options list-buffers -F '#{buffer_name}'))

    for buffer in ${buffers}; do

      local buffer_text=$($tmux $tmux_options show-buffer -b $buffer)

      # echo "using: $buffer_text"
      # echo "$buffer_text" | xclip -i -selection primary
      # echo "$buffer_text" | xclip -i -selection clipboard

      redis-cli --raw zadd 'clipboard' $(date +%s) "$buffer_text" 1> /dev/null

      # redis-cli --raw zrevrange 'clipboard' 0 0 | xclip -i -selection clipboard 
      # redis-cli --raw zrevrange 'clipboard' 0 0 | xclip -i -selection primary 

    done

    local clipboard=$(redis-cli --raw zrevrange clipboard 0 0)
    
    if [[ $clipboard ]]; then
      # echo $clipboard | xclip -i -selection secondary
    fi

    # }}}

  done

  # }}}

done

# }}}

# Dead code {{{

# for session in ${sessions[@]}; do
#   print 'session:' $session

#   IFS=$'\n' windows=($($tmux $tmux_options list-windows -a -F "#{session_id}:#{window_id}"))

#   # TODO: Group windows by session_group, not session_id

#   for window in ${windows[@]}; do
#     print $'\t\t''window:' $window

#     IFS=$'\n' panes=($($tmux $tmux_options list-panes -t $window -F "#{pane_pid}"))

#     for pane in ${panes[@]}; do
#       print $'\t\t\t\t''pane:' $pane
#     done

#   done
# done

# }}}

# copy tmux variables into redis hash {{{

for field in ${tmux_variables[@]}; do

  continue

  IFS=$'\n' windows=($($tmux $tmux_options list-windows -a -F "$identify:#{$field}"))

  session_array=()

  typeset -A field_values

  field_values=()

  for window in ${windows}; do

    local key=$(echo $window | cut -z -d':' -f1-5)

    # local hostname=$(echo $window | cut -d':' -f1)
    # local window_group=$(echo $window | cut -d':' -f2)
    # local line=$(echo $window | cut -d':' -f3)
    local window_id=$(echo $window | cut -d':' -f4)
    local window_id=$(echo $window | cut -d':' -f5)

    local value=$(echo $window | cut -z -d':' -f6- | sed ':a;N;$!ba;s/\n//g')

    # local key=$(echo $hostname:$session_group:$line:$session_id:$window_id)

    # echo $key $field $value

    redis-cli --raw hmset $key $field $value 1> /dev/null &
    local window_target="$session_id:$window_id"

    IFS=$'\n' panes=($($tmux $tmux_options list-panes -t $window_target -F "#{pane_pid}"))

    # echo $panes

    # field_values+=($key "$field $value")

  done

done

# }}}

# for value in "$(print ${(kv)field_values})"; do
#   echo $value
# done

# for key in "${field_values[*]}"; do
  # echo $key
  # echo ${field_values[0]}
# done

# echo 'done'

# }}}

}

do_stuff

