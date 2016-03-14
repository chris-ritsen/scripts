#!/usr/bin/zsh

function open_url() {

local url=${*}

if [[ -z "${BROWSER}" ]]; then 
  BROWSER=/usr/bin/chromium
fi

if [[ -z "${url}" ]]; then 
  return
fi

cd /tmp

if [[ "${url}" =~ 'thepiratebay' ]]; then

  curl -s "$url" | grep -oe 'magnet:.*" ' | sed -e 's/"//g' | sort -u | xargs transmission-remote -a

  return

fi

if [[ "${url}" =~ 'youtube.com' ]]; then
  youtube-dl "${url}"
fi

if [[ "${url}" =~ 'sprunge' ]]; then

  id=$(echo "${url}" | cut -d '/' -f 4 | sed -e 's/?.*$//')
  url='http://sprunge.us/'"$id"

  wget --quiet "$url"

  file="/tmp/$id"
  # wc "/tmp/$id"

  # tmux load-buffer -b test $file
  local tmux_socket='/home/chris/.tmp/tmux/tmux-1000/admin'

  tmux -S "${tmux_socket}" load-buffer -b sprunge '/tmp/'"${id}"
  tmux -S "${tmux_socket}" run-shell -t :5.1 "cat /tmp/${id}"
  
  # less $file

  return

fi

if [[ "${url}" =~ 'imgur' ]]; then 

  id=$(echo "$*" | cut -d'/' -f4)

  alias feh='feh --hide-pointer --scale-down --image-bg black --fullscreen'

  alias wget='wget --no-clobber'

  wget --quiet "${url}" && DISPLAY=:0 feh "${id}"

  return

fi

"${BROWSER}" "${url}" 2>/dev/null

}

open_url ${*}

# "${BROWSER}" ${*}

