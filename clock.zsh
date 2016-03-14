#!/usr/bin/zsh

task=$(/usr/bin/emacsclient  --eval "(message org-clock-heading)" | sed -e 's/"//g')
home='bec04a8b-33b5-4a21-b929-a0e87b7d41fd'
commute='54bbeb29-7a63-4f63-a02f-7c52e19ee0af'

if [[ ${task} == 'Commute' ]]; then 
  # echo "'$task'"

  ssh -q iphone exit;

  if [[ $? != 0 ]]; then 
    exit
  fi

  /usr/bin/emacsclient --eval "(org-id-goto \"$home\")" --eval "(org-clock-in)" 1>/dev/null

elif [[ ${task} == 'Home' ]]; then 

  /usr/bin/emacsclient --eval "(org-id-goto \"$commute\")" --eval "(org-clock-in)" 1>/dev/null 

fi      

