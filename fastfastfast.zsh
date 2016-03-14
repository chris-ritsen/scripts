#!/usr/bin/zsh

while read line; do

  sleep 0.01;
  echo -n "$line";
  echo -n "\n\n\n";

done < notes

