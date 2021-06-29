#!/bin/bash
version="0.0.6"

# open several panes in byobu to monitor DNS and DHCP 

function checks(){
    # check if we're running as a user
    if [[ $(id -u) -eq 0 ]]
    then
        printf "Run as a normal user"
    fi
    if [[ -z ${TMUX} ]]
    then    
      printf "Tmux not running yet"
    fi
}

function open_pane() {
    name=$1
    shift
    size=$1
    shift
    cmd=${@}
    byobu -S ${TMUX} split-window -d -l ${size}
}

checks