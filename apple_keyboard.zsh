#!/usr/bin/zsh

function() {

local match_id='Apple Inc. Apple Keyboard'

IFS=$'\n' ids=($(xinput list --id-only))

for id in ${ids[@]}; do

  # Use id to find line number

  # Check if model string matches given for that device id on that line number

  local line_number=$(xinput list --id-only | grep -ne "${id}" | head -n 1 | cut -d ':' -f 1) 

  local line=$(xinput | grep 'id='"${id}")

  if [[ ! "${line}" =~ "${match_id}" ]]; then

    continue

  fi

  xkbcomp -w 0 -i "${id}" -I/home/chris/.scripts/xkb/ /home/chris/.scripts/xkb/apple.xkb "${DISPLAY}"

done

xset r rate 200 120

}

