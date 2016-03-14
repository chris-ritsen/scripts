#!/usr/bin/zsh

# Common {{{

# global for no good reason {{{

socket=''

# }}}

# choose episodes {{{

function choose_episodes() {

  local show=$*

  if [[ -z $show ]]; then
    return
  fi

  local playlist='playlist:'"$show"

  if [[ $(redis-cli --raw exists $playlist) == 0 ]]; then
    return
  fi

  fzf_options=(--ansi --black --color=bw --expect=ctrl-j --inline-info --no-hscroll --prompt="" --tac -i -m -x) 
  local fzf_bin='/usr/bin/fzf' 

  episodes=$(redis-cli zrange $playlist 0 -1 | sort)

  episodes=$(echo $episodes | FZF_DEFAULT_OPTS=${fzf_options[@]} ${fzf_bin})

  episodes=$(echo $episodes | sed -e 's/^ctrl-j$//g' | sed ':a;N;$!ba;s/\n\n//g')

  echo $episodes

}

# }}}

# choose shows {{{

function choose_shows() {

  # for show in $shows
  #   if [[ -z $(zrangebyscore 'playlist:'"$show" 0 0) == 0 ]]; then
  #   fi
  # done

  fzf_options=(--ansi --black --color=bw --expect=ctrl-j --inline-info --no-hscroll --prompt="" --tac -i -m -x) 
  local fzf_bin='/usr/bin/fzf' 

  shows=$(redis-cli keys 'playlist:*' | sed -e 's/playlist://g' | sort)

  shows=$(echo $shows | FZF_DEFAULT_OPTS=${fzf_options[@]} ${fzf_bin})

  shows=$(echo $shows | sed -e 's/^ctrl-j$//g' | sed ':a;N;$!ba;s/\n\n//g')

  echo $shows

}

# }}}

# get socket {{{

function get_socket() {

  if [[ -z $socket ]]; then
    socket=$(redis-cli --raw get 'socket')
  fi

  echo $socket

}

# }}}

# string join {{{

function join() {

  local IFS="$1"; shift; echo "${*}";

}

# }}}

# badly format json for mpv {{{

function make_json() {

  local json='{ "command": '

  json+='[ '

  values=()

  for value in ${*}; do
    values+='"'${value}'" '
  done

  json+=$(join ',' ${values})

  json+=' ] }'

  echo $json | underscore print

}

# }}}

# get video files from hard-coded path {{{

function get_video_files() {

  videos=$(find '/Media/TV/star_trek/star_trek.voyager/' -type f -regex ".*\.\(mkv\)")

  IFS=$'\n' videos=($(echo "$videos"))

  echo "${videos[@]}"

}

# }}}

# query mpv json api {{{

function mpv_query() {

  local socket=$(get_socket)
  local json=$1

  if [[ -z $json || -z $socket || ! -S $socket ]]; then
    return
  fi

  local value=$(echo $json | socat - $socket 2> /dev/null)

  if [[ -z $value ]]; then
    return
  fi

  value=$(echo $value | underscore --outfmt text extract data 2>/dev/null)

  if [[ $value == 'null' ]]; then
    return
  fi

  echo $value

}

# }}}

# get mpv property as string {{{

function get_property_string() {

  local property=$1
  local command='get_property_string'

  local json=$(make_json $command $property)

  mpv_query $json

}

# }}}

# get mpv property {{{

function get_property() {

  local property=$1
  local command='get_property'

  local json=$(make_json $command $property)

  mpv_query $json

}

# }}}

# set mpv property {{{

function set_property() {

  local property=$1
  local value=$2
  local command='set_property'

  if [[ -z $property || -z $value ]]; then
    return
  fi

  # local json=$($command $property $value)
  local json='{ "command": ["'$command'", "'$property'", '$value'] }'

  mpv_query $json

}

# }}}

# assign string value to mpv property {{{

function set_property_string() {

  local property=$1
  local value=$2
  local command='set_property_string'

  if [[ -z $property || -z $value ]]; then
    return
  fi

  local json=$(make_json $command $property $value)

  mpv_query $json

}

# }}}

# clear mpv playlist (except current) {{{

function playlist_clear() {

  local command='playlist-clear'

  local json=$(make_json $command)

  mpv_query $json 1>/dev/null

}

# }}}

# stop mpv playback {{{

function stop_playback() {

  local command='stop'

  local json=$(make_json $command)

  mpv_query $json 1>/dev/null

}

# }}}

# remove the current playlist item from mpv {{{

function playlist_remove_current() {

  local command='playlist-remove'
  local index='current'

  local json=$(make_json $command $index)

  mpv_query $json 1>/dev/null

}

# }}}

# replace mpv playlist with an input file containing media paths {{{

function playlist_load_replace() {

  local command='loadlist'
  local filename=$1
  local mode='replace'

  if [[ ! -f $filename ]]; then
    return
  fi

  local json=$(make_json $command $filename $mode)

  mpv_query $json 1>/dev/null

}

# }}}

# append mpv playlist with an input file containing media paths {{{

function playlist_load_append() {

  local command='loadlist'
  local filename=$1
  local mode='append'

  if [[ ! -f $filename ]]; then
    return
  fi

  local json=$(make_json $command $filename $mode)

  mpv_query $json 1>/dev/null

}

# }}}

# playlist append using loadfile {{{

function playlist_append() {

  local command='loadfile'
  local filename=$1
  local mode='append'

  if [[ ! -f $filename ]]; then
    return
  fi

  local json=$(make_json $command $filename $mode)

  mpv_query $json 1>/dev/null

}

# }}}

# playlist clear {{{

function playlist_clear() {

  local command='playlist-clear'

  local json=$(make_json $command)

  mpv_query $json 1>/dev/null

}

# }}}

# playlist next {{{

function playlist_next() {

  local command='playlist-next'

  local json=$(make_json $command)

  mpv_query $json 1>/dev/null

}

# }}}

# playlist count {{{

function playlist_count() {

  get_property 'playlist/count'

}

# }}}

# get current file path from mpv {{{

function get_file_path() {

  get_property 'path'

}

# }}}

# redis {{{

# {{{

function get_playlist() {
  # TODO: select among different playlists for different shows

  echo 'playlist'
}

# }}}

# {{{

function get_last_watched() {

  local playlist=$(get_playlist)

  local last=$(redis-cli --raw zrangebyscore $playlist 0 0 limit 0 1)

  echo $last

}

# }}}

# {{{

function get_watched() {

  local playlist=$(get_playlist)

  redis-cli --raw zrangebyscore $playlist 1 1 limit 0 -1

}

# }}}

# {{{

function get_watched_count() {

  local playlist=$(get_playlist)

  local count=$(redis-cli --raw zrevrangebyscore $playlist 1 1 limit 0 1 | wc -l)

  echo "${count}"

}

# }}}

# {{{

function get_unwatched() {

  local playlist=$(get_playlist)

  redis-cli --raw zrange $playlist 0 -1

}

# }}}

# {{{

function clear_playlist() {
  redis-cli --raw del playlist 1>/dev/null

  if [[ ! $(get_property 'playlist/count' | bc) -eq 0 ]]; then
    playlist_clear
  fi
}

# }}}

# {{{

function mark_watched() {

  local filename=$1

  if [[ -z $1 ]]; then

    filename=$(get_file_path)

  fi

  local show=$(echo $filename | xargs dirname | xargs basename)

  local playlist='playlist:'"$show"

  redis-cli --raw set 'watched' 'false'

  redis-cli zrem 'playlist' $filename 1>/dev/null

  redis-cli zadd $playlist XX '1' $filename 1>/dev/null

}

# }}}

# {{{

function skip_show() {

  local show=$1
  local episode=$2
  local intro_start=$3
  local intro_end=$4
  local credits_start=$5

  if [[ -z $show || -z $episode ||  -z $intro_start || -z $intro_end || -z $credits_start ]]; then
    return
  fi

  local time=$(get_property 'time-pos' | bc)

  if [[ $(echo "$time > $intro_start" | bc) -eq 1 && $(echo "$time < $intro_end" | bc) -eq 1 ]]; then
    set_property 'time-pos' $intro_end
  fi

  if [[ $(echo "$time > $credits_start" | bc) -eq 1 ]]; then
    playlist_next
  fi

  echo $show $episode $time

}

# }}}

# {{{

function set_episode_title() {

  local video=$(get_property 'path')

  if [[ -z $video || ! -f $video ]]; then
    return
  fi

  local choice=''

  local episode=$(/usr/bin/redis-cli --raw hget $video 'episode')

  local episode_title=$(/usr/bin/redis-cli --raw hget $video 'title')

  local show=$(echo $video | xargs dirname)

  local show_title=$(/usr/bin/redis-cli --raw hget $show 'title')

  if [[ -z $show_title ]]; then
    show_title=$(echo $show | xargs basename)

    echo -n 'Show title? ('"$show_title"'): '

    vared -h show_title

    if [[ -z $show_title ]]; then
      return
    fi

    echo 'Show title:' $show_title
    /usr/bin/redis-cli --raw hset $show 'title' "$show_title" 1> /dev/null

  fi

  if [[ -z $episode_title ]]; then

    # TODO: Recognise other filenames here

    episode_title=$(echo $video | xargs basename -s'.mkv')

  fi

  echo -n 'Episode title? ('"$episode_title"'): '

  vared -h -p 'Episode title?' episode_title

  if [[ -z $episode_title ]]; then
    return
  fi

  echo 'Episode title:' $episode_title
  /usr/bin/redis-cli --raw hset $video 'title' "$episode_title" 1> /dev/null

}

# }}}

# {{{

function watched_show() {

  # This function prompts the user for one or more shows that have files 
  # added, then asks for one or more episodes of each show to be marked as 
  # watched.

  shows=($(choose_shows))

  for show in $shows; do
    # echo 'show:' $show

    local playlist='playlist:'"$show"

    videos=($(choose_episodes $show))

    for video in $videos; do

      # echo 'video:' $video

      # TODO: bulk add

      redis-cli zadd $playlist XX 1 $video 1> /dev/null

    done

  done

}

# }}}

# {{{

function add_videos_to_playlist() {

  return

  local playlist=$(get_playlist)

  local score='0' # unwatched
  echo 'add videos to playlist'

  local members=''

  for video in $(get_video_files); do
    # Skips re-scoring existing entires
   members+=" $score $video"
  done

  if [[ -z $members ]]; then
    return
  fi

  members=$(echo $members | sed ':a;N;$!ba;s/\n//g')

  # redis-cli --raw del $playlist
  redis-cli --raw zadd $playlist NX $(echo "$members") 1>/dev/null

  redis-cli --raw zcard $playlist
}

# }}}

# {{{

function mark_earlier_watched() {

  echo 'mark earlier'

  local current=$*
  local playlist=$(get_playlist)

  current=$(echo $current | sed ':a;N;$!ba;s/\n//g') 

  local videos=$(redis-cli --raw zrangebylex $playlist - "[$current")

  IFS=$'\n' videos=($(echo "$videos"))

  local score='1'

  local members=''

  for video in "${videos[@]}"; do
    # Skips re-scoring existing entires
    members+=$(echo " '$score' '$video'")
  done

  if [[ -z $members ]]; then
    return
  fi

  members=$(echo $members | sed ':a;N;$!ba;s/\n//g')

  echo redis-cli --raw zadd $playlist XX $(echo $members)
  redis-cli --raw zadd $playlist XX $(echo $members)
  echo 'after'

  redis-cli --raw zcard $playlist
}

# }}}

# }}}

# actions {{{

function initialise_playlist() {

  shows="${*}"

  for show in "${@}"; do
    # echo 'show:' $show
  done

  local current=$(get_property path)

  if [[ -z $current ]]; then

    videos=$(get_unwatched)

    # current=$(echo $videos | sort -u | choose_episode | sed ':a;N;$!ba;s/\n//g')

    # if [[ -z $current ]]; then
    #   return
    # fi

    # mark_earlier_watched $current
  fi

  local playlist_file='/tmp/video_playlist'

  # watched=$(redis-cli --raw zrangebylex $(get_playlist) - "($current")

  watched=$(get_watched)
  unwatched=$(get_unwatched)

  for video in $(get_watched); do
    # echo 'watched:' $video
  done

  for video in $(get_unwatched); do
    # echo 'unwatched:' $video
  done

  # clear_playlist

  add_videos_to_playlist

  # TODO: is the current video unwatched?  Is the previous video unwatched?

  # mark_earlier_watched $current

  if [[ -z $current ]]; then
    current=$(echo $unwatched | head -n1)
  fi

  echo 'current:' $current

  local time_pos=$(redis-cli --raw get 'time_pos')
  local pause=$(redis-cli --raw get 'pause')

  if [[ $(get_property path) == $current ]]; then
    echo 'here'
    videos=$(redis-cli --raw zrangebyscore $(get_playlist) 0 0 limit 1 -1)

    echo $videos > $playlist_file

    playlist_clear
    playlist_load_append $playlist_file

  else
    echo 'there'
    # videos=$(redis-cli --raw zrangebyscore $(get_playlist) 0 0)

    echo $unwatched > $playlist_file

    stop_playback

    playlist_load_replace $playlist_file
    
    set_property 'playlist-pos' 0

  fi

  current=$(get_property path) 

  # get_property playlist

  playlist_count

  echo 'actual:' $current

  set_property 'time-pos' $time_pos
  set_property 'pause' $pause
  
  return

  # # Old junk beyond here

  # local playlist_json=$(echo '[ ' $(join ',' $(get_property 'playlist')) ']')

  # # echo $playlist_json | underscore --outfmt text pluck 'filename' | sort -u
  # return

  # if [[ ! $(playlist_count | bc) -gt $(get_unwatched | wc -l | bc) ]]; then
  #   echo 'Need to clear playlist because it has too many entries'
  #   # playlist_clear
  #   # add_videos_to_playlist
  # fi

  # for video in $(get_watched); do
  #   redis-cli --raw zadd playlist '1' $video 1>/dev/null
  # done

  # for video in $(get_unwatched); do
  #   playlist_append $video
  # done

  # echo 'playlist count:' $(playlist_count) 

  # local watched=$(redis-cli --raw get 'watched')

  # if [[ $watched == 'true' ]]; then

  #   redis-cli --raw set 'watched' 'false' 1>/dev/null

  #   # TODO: increment instead

  #   redis-cli --raw zadd playlist '1' $video 1>/dev/null

  #   echo 'Advance to next video'

  #   # playlist_count
  #   playlist_next

  # else

  #   set_property 'playlist-pos' 0
  #   # set_property 'pause' 'no' 

  # fi

  # TODO: Union sets to play the next episode from one or more shows in any 
  # order, such as the next episode or voyager, then enterprise, then 
  # enterprise, then voyager.  Or, select a show and play next voyager, next 
  # voyager, etc.

}

# }}}

# set episode and show title {{{

function set_title() {

# FIXME: No idea why this isn't finding redis-cli as a command.

  local video=$(get_property 'path')

  if [[ -z $video || ! -f $video ]]; then
    return
  fi

  local choice=''

  local episode=$(/usr/bin/redis-cli --raw hget $video 'episode')

  local episode_title=$(/usr/bin/redis-cli --raw hget $video 'title')

  local show=$(echo $video | xargs dirname)

  local show_title=$(/usr/bin/redis-cli --raw hget $show 'title')

  if [[ -z $show_title ]]; then
    show_title=$(echo $show | xargs basename)

    echo -n 'Show title? ('"$show_title"'): '

    vared -h show_title

    if [[ -z $show_title ]]; then
      return
    fi

    echo 'Show title:' $show_title
    /usr/bin/redis-cli --raw hset $show 'title' "$show_title" 1> /dev/null

  fi

  if [[ -z $episode_title ]]; then

    # TODO: Recognise other filenames here

    episode_title=$(echo $video | xargs basename -s'.mkv')

  fi

  # echo -n '('"$episode_title"'): '

  vared -h -p 'Episode title: ' episode_title

  if [[ -z $episode_title ]]; then
    return
  fi

  /usr/bin/redis-cli --raw hset $video 'title' "$episode_title" 1> /dev/null


}

# }}}

# main loop for mpv {{{

function main_player() {

  # TODO: Make this subscribe to something on redis so that this script blocks 
  # until it receives an event to start watching videos, instead of running this 
  # script over and over again.

  # TODO: how to signal being done with watching videos?

  # {{{

  local started=$(redis-cli --raw get 'started')

  if [[ $started != 'true' ]]; then
    return
  fi

  local pause=$(get_property 'pause')  
  local socket=$(redis-cli --raw get 'socket')
  local socket_time_pos=''
  local time_pos=$(get_property 'time-pos')
  local video=$(get_property 'path')  
  local watched=$(redis-cli --raw get 'watched')

  if [[ -z $socket ]]; then

    socket='/home/chris/.tmp/mpv/video'

    redis-cli --raw set 'socket' $socket 1> /dev/null

  fi

  if [[ $watched == 'true' ]]; then

    mark_watched
    playlist_next

  fi

  if [[ $video ]]; then

    local show=$(echo $video | xargs dirname)
    local episode=$(echo $video | xargs basename -s '.mkv')  

    properties=($(get_property property-list | grep -e '^time-'))

    properties+=(

      'length'
      'pause'

    )

    local last_known_time=$(redis-cli --raw hget $video 'time-pos')

    echo $last_known_time

    for property in $properties; do

      redis-cli --raw hset $video $property $(get_property $property)

    done

    properties=(

      'episode' $episode

    )

    redis-cli --raw hmset $video $properties

    local show_title=$(redis-cli --raw hget $show 'title' 2> /dev/null)
    local episode_title=$(redis-cli --raw hget $video 'title' 2> /dev/null)

    if [[ $(echo $time_pos) -lt $(echo $last_known_time) ]]; then
      # set_property 'time-pos' $last_known_time
    fi

    if [[ -z $show_title ]]; then
      show_title=$show
    fi

    if [[ $episode_title ]]; then
      redis-cli set 'now_playing' "$show_title - $episode - $episode_title"
    else
      redis-cli set 'now_playing' "$show_title - $episode"
    fi

  else

    redis-cli --raw del now_playing 1> dev/null

  fi

  if [[ $(ps ax | grep "mpv.*$video" | wc -l) == '1' ]]; then

    systemctl --user start movie.service

    # Should seed the playlist after it restarts

  else

    systemctl --user start mpv_events.service

    ./playlist.zsh

    redis-cli --raw set playlist_count $(get_property 'playlist/count')  

  fi

  # }}}

  # dead code {{{

  return

  # if [[ -z $video ]]; then
  #   redis-cli --raw set 'video' $filename 1> /dev/null 
  # else
  #   if [[ $video != $filename ]]; then
  #     video=$filename
  #     redis-cli --raw set 'video' $filename 1> /dev/null 
  #   fi

  #   local pause=$(get_property 'pause')

  #   if [[ -z $pause ]]; then
  #     pause=$(redis-cli --raw get 'pause')
  #   fi

  #   if [[ $started == 'true' && $pause == 'true' ]]; then
  #     echo 'should be started, but paused'
  #   fi

  #   if [[ $started == 'true' && $pause == 'false' ]]; then
  #     echo 'should be started and playing now'
  #   fi

  #   if [[ $started == 'false' ]]; then
  #     systemctl --user stop movie.service
  #     return
  #   fi

  #   if [[ -S $socket ]]; then
  #     # use this socket and play the video
  #     # local time=$(get_property 'time-pos' | bc)

  #     if [[ $pause != $(redis-cli --raw get 'pause') ]]; then
  #       $pause=$(redis-cli --raw get 'pause')
  #       set_property 'pause' $pause
  #     fi

  #     time_pos=$(get_property 'time-pos')

  #     if [[ -z $time_pos ]]; then
  #       time_pos=$(redis-cli --raw get 'time_pos')
  #     fi

  #     if [[ -z $time_pos ]]; then
  #       time_pos=0
  #     fi

  #     # if [[ $(echo $time_pos | bc) != $time_pos ]]; then
  #     #   time_pos=0
  #     # fi

  #     echo $time_pos $(echo $video | xargs basename -s .mkv)

  #     local pause=$(get_property 'pause')
  #     redis-cli --raw set 'time_pos' $time_pos 1> /dev/null
  #     socket_time_pos=$time_pos
  #     redis-cli --raw set 'pause' $pause 1> /dev/null

  #   else
  #     # start playing the video
  #     # mpv --playlist=playlist --input-unix-socket=$socket
  #   fi

  #   if [[ $(echo $time_pos | bc) != $time_pos ]]; then
  #     time_pos=0
  #   fi

  #   if [[ $time_pos != $socket_time_pos ]]; then
  #     time_pos=$socket_time_pos
  #     redis-cli --raw set 'time_pos' $time_pos 1> /dev/null
  #   fi

  #   if [[ -z $(xdotool search --desktop 1 --screen 0 --onlyvisible --name mpv getwindowname) ]]; then
  #     xdotool key --clearmodifiers 'super+e+3'

  #     # TODO: video should not restart if hidden underneath another window
  #   else
  #     local video_pid=$(xdotool getactivewindow getwindowpid)

  #     if [[ $(ps -q $video_pid -o comm=) =~ 'mpv' ]]; then
  #       xdotool key --clearmodifiers 'super+e+3'
  #     fi

  #   fi

  # fi

}

# }}}

# }}}

# events {{{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   

function event_handler() {

local event=$1

case $event in
pause*)
  echo 'pause!'
  redis-cli --raw set pause $(get_property 'pause') 1> /dev/null 
  ;;
unpause*)
  echo 'unpause!'
  redis-cli --raw set pause $(get_property 'pause') 1> /dev/null
  ;;
end-file*)
  echo 'file ended!'
  echo $event
  echo $(get_property 'filename') 
  ;;
file-loaded*)
  echo 'loaded new file!' $(get_property 'filename')
  echo $event
  echo $(get_property 'filename') 

  ;;
*)
	echo $event
  ;;
esac

# echo  $(

# get_property 'filename';
# get_property 'length';
# get_property 'percent-pos';
# get_property 'time-pos';
# get_property 'time-remaining';
# get_property 'path';
# get_property 'playlist/count';

# )

}

# }}}

# event loop {{{

function event_loop() {

  local event=$1

  if [[ $event ]]; then
    event=$(echo $event | underscore --outfmt text extract 'event' 2>/dev/null)
  fi

  if [[ -z $event ]]; then
    return
  fi

  redis-cli --raw set pause $(get_property 'pause') 1> /dev/null 

  event_handler $event

}

# }}}

# watch mpv events {{{

function watch_events() {

  # Guard {{{

  if [[ $(ps ax | grep "mpv.*$video" | wc -l) == '1' ]]; then
    return
  fi

  # }}}

  local socket=$(get_socket)
  
  # redis-cli set event $socket 1> /dev/null

  stdbuf -o0 socat - $socket | (

  while true; do 
    read buffer;

    if [[ -z $buffer ]]; then
      continue
    fi

    # redis-cli set event $buffer 1> /dev/null

    event_loop $buffer;
  done

  )

}

# }}}

# choose episode now {{{

function choose_episode_now() {

  # This function prompts the user for one or more shows that have files 
  # added, then asks for one or more episodes of each show to be marked as 
  # watched.

  shows=($(choose_shows))

  for show in $shows; do
    # echo 'show:' $show

    local playlist='playlist:'"$show"

    videos=($(choose_episodes $show))

    for video in $videos; do

      # echo 'video:' $video

      # TODO: bulk add

      redis-cli zadd $playlist XX 1 $video 1> /dev/null

    done

  done

}

# }}}

# do it already {{{

function do_it() {

  shows=($(choose_shows))

  local temp_dir='/tmp/merge_playlists'

  rm -rf $temp_dir 2>/dev/null
  mkdir -p $temp_dir

  for show in $shows; do

    echo 'show:' $show

    local playlist='playlist:'"$show"

    # episodes+=($(redis-cli --raw zrangebyscore $playlist 0 0))
    redis-cli --raw zrangebyscore $playlist 0 0 > "$temp_dir"'/'"$show"

  done

  if [[ -z $(find $temp_dir -type f) ]]; then
    return
  fi

  episodes=($(paste -d '\n' $temp_dir/* 2>/dev/null | sed -e '/^$/d'))

  rm -rf $temp_dir/* 2>/dev/null

  if [[ -z $episodes ]]; then
    redis-cli set started 'false' 1> /dev/null
    systemctl --user stop movie.service

    return
  fi

  redis-cli --raw del 'playlist' 1> /dev/null

  local index=0

  for episode in $episodes; do

    # echo 'episode:'$episode

    redis-cli --raw zadd 'playlist' $index $episode 1> /dev/null

    index=$(($index + 1))

  done

  redis-cli --raw set started 'true' 1> /dev/null
  systemctl --user start movie.service

}

# }}}

# start the player {{{

function player_go() {

local started=$(redis-cli --raw get 'started')

if [[ -z $started || $started == 'false' ]]; then
  return
fi

local socket=$(redis-cli --raw get 'socket')

if [[ -z $socket ]]; then
  socket='/home/chris/.tmp/mpv/video'
fi

# TODO: Consider using redis features like rpoplpush to move items around a 
# list to indicate watched shows.  Something like that.

# skipping time position and pause state for now

local command="mpv --input-unix-socket=$socket --force-window=yes --keep-open=yes --idle"

# TODO: Use xdotool and search for mpv on all windows instead of this

if [[ $(ps ax | grep "mpv.*$socket" | wc -l) == '1' ]]; then

  # FIXME: Never type into an active window

  # TODO: Use xmonad server mode

  xdotool key --clearmodifiers 'super+e+3'

  zsh -c $command
fi

}

# }}}

# add shows to playlist {{{

function add_playlist() {

  shows="${*}"

  local unwatched=0
  local watched=1

  for directory in "${@}"; do
    show=$(basename $directory)

    local playlist='playlist:'"$show"

    echo 'show:' $show

    videos=$(find $directory -type f -regex ".*\.\(mkv\|avi\|m4v\|mp4\)")

    IFS=$'\n' videos=($(echo "$videos"))

    redis-cli --raw del $playlist 1> /dev/null

    for video in "${videos[@]}"; do

      if [[ $video =~ 'extra' ]]; then
        continue
      fi

      if [[ $video =~ 'low' ]]; then
        continue
      fi

      if [[ ! $video =~ 's..e..' ]]; then
        continue
      fi

      # echo 'episode:' $video

      redis-cli --raw zadd $playlist NX $unwatched $video 1> /dev/null

    done

    echo 'episodes:' $(redis-cli --raw zcard $playlist)

  done

}

# }}}

# }}}

