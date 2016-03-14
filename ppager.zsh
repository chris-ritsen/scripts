#!/usr/bin/zsh

# echo 'shell args'':' "$*"

# TODO: Specify a socket for this.

session='chris:1.1'
session_b='chris:2.1'

pager_sdcv() {

local SDCV_PAGER='cat'

# echo 'function args'':' "$*"

loca definitely=$('sdcv' "$*")

tmux set-buffer -b 'sdcv' ${definitely}
tmux run-shell -t $session "tmux respawn-pane -k -t $session -- 'tmux show-buffer -b sdcv | less'"
tmux run-shell -t $session "tmux display-message -t $session -- test"

# tmux run-shell -t 1 'tmux respawn-pane -t 1 "tmux show-buffer -b sdcv | less"'

# echo ${definitely} | xargs -0 -I {} tmux set-buffer -b 'sdcv' "{}"
# echo 'most'':' $definitely
# echo 'tmux buffer'':' "$(tmux show-buffer)"
# tmux display-message -p -t 4 ''${definitely}
# tmux display-message -t 2 here
# tmux run-shell -t 1 "echo -n 'date'': ' && date && exit"
# tmux run-shell -t 1 "man ssh"
# tmux run-shell -t chris:1 'tmux display-message -c 1 fuck'
# tmux run-shell -t chris:1 'tmux show-buffer -b sdcv'

}

pager() {

local cmd=$(echo $*)

tmux set-buffer -b 'mp' ${cmd}
tmux run-shell -t $session "tmux respawn-pane -k -t $session -- 'man $cmd'"
tmux run-shell -t $session_b "tmux respawn-pane -k -t $session_b -- '(echo $cmd; which $cmd; pacman -Ql | grep -e $cmd | grep 'bin/') | less'"
# tmux run-shell -t $session_b "tmux respawn-pane -k -t $session_b -- 'pacman -Ql $cmd' | less"

}

# which pager

pager "$*"

