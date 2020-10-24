#!/bin/bash
version=0.9.1  # developing
# create terminals and rename
# TODO: run command between brackets from configfile
configFile=~/.config/byobu_windows.cfg


function extract_session() {
    arg=$1
    [[ ! "${line:0:1}" = "[" ]] && echo Not a session block && exit 1
    [[ ! "${line: -1}" = "]" ]] && echo Not a session block && exit 1
    echo "${arg:1:-1}"
}

function new_session(){
    sess=$1
    if [[ $(byobu has-session -t ${sess} &> /dev/null; echo $?) -eq 0 ]] 
    then
      echo Session ${sess} already exists
    else
      printf "Starting new session %s\n" "${sess}"
      byobu new-session -d -s ${sess}
    fi
}

function new_window(){
    win=$1
    printf "Window %s: %s\n" "${win_id}" "${win}"
    if [[ ${win_id} -eq 0 ]]
    then
	byobu rename-window -t ${win_id} ${win}
    else
	byobu new-window -n ${win} 
    fi
    byobu select-pane -t ${pane_id} -T ${win}
}

function new_pane(){
    pane_name=$1
    printf "\t%s\t%s %s\n" ${pane_id} "${pane_name}" "${split}"
    byobu select-window -t ${win_id}
    byobu split-window ${split}
    byobu select-pane -t ${pane_id} -T ${pane_name}
    
}

while read line
do
    if [[ "${line:0:1}" = "[" ]]
    then
	# begin SESSION
	SESSION=$(extract_session ${line})
	new_session ${SESSION}
	win_id=0
    else
	pane_id=0
	# create windows with panes
	for pane in ${line[@]}
	do
	    if [[ "${pane:0:1}" = "|" ]]
	    then
		# create horizontal pane
		pane=${pane: 1}
		split=-h
	    else
		# create vertical pane
		split=-v
	    fi
	    if [[ ${pane_id} -eq 0 ]]
	    then
		new_window ${pane}
	    else
		new_pane ${pane}
	    fi
	    pane_id=$((pane_id+1))
	done
	win_id=$((win_id+1))
	printf "\n"
    fi
    
done < ${configFile}

nohup  byobu -S guake &