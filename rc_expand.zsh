#!/usr/bin/zsh

a=(1 2 3)

echo ${^a}.txt

setopt RC_EXPAND_PARAM

echo ${a}.txt

