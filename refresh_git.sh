#!/bin/bash
version='0.0.78'
# Sam Van Kerckhoven <sam.vankerckhoven@cipalschaubroeck.be>   07-06-2020
# 
# sysutils/refresh_git.sh
# script that refresh git and opens a new pane once when in tmux to display the status in color

window_name=refresh
pane_name=watchgit
watch_pane_height=6
marge=1
termheight=$(tput lines)
function get_tmux_session(){
    if [[ $USER -ne ansible ]]
    then
        [[ -z ${SUDO_UID} ]] && echo No SUDO_UID. Did you sudo twice ? \n Try running /usr/local.bin/refresh_git.sh as yourself && exit 1
        session=/tmp/tmux-${SUDO_UID}/default
    else
        session=/tmp/tmux-${UID}/default
    fi
}
function check_pane() {
    if [[ $(sudo byobu -S ${session} list-panes | wc -l) -gt 1 ]]
    then
        echo 0
    else
        echo 1
    fi
}
function check_window() {
    find_title=$(sudo byobu -S ${session} list-windows | grep -e '\ '"${window_name}"'[\ *-]')
    if [[ -n ${find_title} ]] 
    then
      echo 0
    else
      echo 1
    fi

}
function resize_pane(){
    height=$watch_pane_height

    if [[ -n $termheight ]]
    then
        inc=$(( (termheight/2) - (height + marge) ))
        printf "Resizing to %s lines\n" "$inc"
        sudo byobu -S ${session} resize-pane -U $inc
    fi
    
}
function new_win() {
    echo TODO
}

function set_watchpane(){
    sudo byobu -S ${session} split-window -v
    sudo byobu -S ${session} send-keys "sudo su - ansible" Enter
    sudo byobu -S ${session} send-keys "watch --color '/usr/local/bin/gitwatch.sh'" Enter
    sudo byobu -S ${session} swap-pane -s 0 -t 1
    sudo byobu -S ${session} select-pane -t 1 
    resize_pane
    # sudo byobu -S ${session} resize-pane 
}
function check_tmux() {
    if [[ ${TERM} == screen ]]
    then
        get_tmux_session
        if [[ $(check_window) -eq 0 ]]    #|| sudo byobu -S ${session} new-window -n ${window_name} 'sudo su - ansible'
        then
            # If there exists a window name refresh, use it
            sudo byobu -S ${session} select-window -t ${window_name}
        fi
        [[ $(check_pane) -eq 0 ]] || set_watchpane
        
        # byobu-tmux send-keys "COMMAND"

    fi
}


check_tmux
sudo su - ansible -c /usr/local/bin/git_pull_ansible.sh
