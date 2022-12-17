#!/bin/bash
cfg=~/.config/ssh_tunnel.cfg
[[ ! -e ${cfg} ]] && echo Config ${cfg} does not exist && exit 1
source ${cfg}
set -x
version="0.3"

function check_running() {
    if [[ $(ps aux | grep ssh | grep -v grep | grep ${port} > /dev/null;echo $?) -ne 0 ]]
    then
        
        connstat=Inactive
    else
        connstat=Active
    fi
}
function connect_tunnel() {
    ssh -fN -R ${port}:localhost:22 -p ${server_port} ${server} & echo $?
}

function remote_log(){
    ssh -p 10023 owncloud.shor.ch "printf '%s:%s:%s\n' $(date +%Y-%m-%d_%H:%M) ${name} ${@} >> remote/${name}.log"
}

function log(){
    printf "%s: %s\n" "$(date)" "${@}" >> /var/log/${name}.log
}

check_running
if [[ ${connstat} != Active ]]
then
    printf "%s\n" "No connection detected. Trying to connect..."
    conn_result=$(connect_tunnel)
    echo Connection Result ${conn_result}
    check_running
    if [[ ${connstat} != Active ]]
    then
        log Connection NOT restored
       
        # connect_tunnel
    fi 
#     ssh -fN -R grep ${port}:localhost:22 -p 10023 owncloud.shor.ch
#     if [[ $(ps aux | grep ssh | grep -v grep | grep grep ${port} > /dev/null;echo $?) -ne 0 ]] 
#  onnstat=Restored
#     fi
#     ssh -p 10023 owncloud.shor.ch 'printf "%s Connection %s\n" "$(date)" "${connstat}" >> ${name}.log' 
fi
set +x
log "Connection ${connstat}"
remote_log ${connstat}