#!/usr/bin/zsh

function() {

if [[ -z "${ID_VENDOR_FROM_DATABASE}" && -z "${ID_MODEL_FROM_DATABASE}" ]]; then
  local match_id='Topre Corporation HHKB Professional'
else
  local match_id="${ID_VENDOR_FROM_DATABASE} ${ID_MODEL_FROM_DATABASE}"
fi

local id=$(xinput list --id-only "${match_id}")

if [[ -z "${id}" ]]; then
  exit 1
fi

xkbcomp -w 0 -i "${id}" -I/home/chris/xkb/ "${HOME}/xkb/hhkb.xkb" "${DISPLAY}"

}

