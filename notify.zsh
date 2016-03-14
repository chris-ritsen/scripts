#!/usr/bin/zsh

app="$1"
summary="$2"
body="$3"

pipe="${XDG_RUNTIME_DIR}/dunst"

if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

date_now=$(date +%H:%M:%S.%1N)

echo "$date_now $app $summary $body" > $pipe

