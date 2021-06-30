#!/bin/bash
version="0.0.13"

# open several panes in byobu to monitor DNS and DHCP 
function warn() {
    boxchar='-'  # ÷
    boxchar2='|'
    msg=${@}
    mlength=${#msg}
    mlength=$((mlength + 4))
    marker=$(printf "${boxchar}%.0s" {1..$mlength})
    printf "   %s\n   ${boxchar2} %s ${boxchar2}\n   %s\n" "${marker}" "${msg}" "${marker}"
}

function checks(){
    # check if we're running as a user
    if [[ $(id -u) -eq 0 ]]
    then
        printf "Run as a normal user"
    fi
    if [[ -z ${TMUX} ]]
    then    
      printf "Tmux not running yet"
      byobu
    fi
    SESSION=${TMUX%%,*}
}

function check_current_pane() {
    if [[ ! -z ${SESSION} ]]
    then
        active_line=$(byobu -S ${SESSION} list-panes | grep active)
        current_pane=${active_line#:*}
    else
        warn No Active Session
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