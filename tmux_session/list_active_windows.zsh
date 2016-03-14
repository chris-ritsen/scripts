#!/usr/bin/zsh

function() {

  IFS=$'\n' keys=($(redis-cli keys $(hostname)'*' | sort))

  for key in ${keys}; do
    local window_active=$(redis-cli --raw hget $key 'window_active')
    local session_attached=$(redis-cli --raw hget $key 'session_attached')
    local window_name=$(redis-cli --raw hget $key 'window_name')

    if [[ $window_active -eq 1 && $session_attached -gt 0 ]]; then
      echo 'key:' $key $window_name
    fi
  done

}

