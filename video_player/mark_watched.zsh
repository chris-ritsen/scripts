#!/usr/bin/zsh

source $HOME/.scripts/video_player/common.zsh

function() {
  redis-cli --raw set 'watched' 'true'
}

