#!/usr/bin/zsh

source $HOME/.scripts/video_player/common.zsh

if [[ $* ]]; then
  if [[ $1 == 'watched' ]]; then
    shift $*
  fi

  add_playlist $*
else
  add_playlist $PWD
fi

