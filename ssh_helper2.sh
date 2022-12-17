#!/bin/bash
# set -x
unset='-'
first=${1}
if [[ ${first: :1} == '-' ]]
then    
    # switch
    switch=${1}
    shift
fi
server=${1}
shift
command=${@}
##########   FUNCTIONS
function log() {
    msg=${@}
    timestamp=$(date '+%F %T')
    if [[ -n ${debug} ]]
    then
        printf "%18s |%s| %s\n" "${timestamp}" "${version}" "${msg}" | tee -a ${logfile}
    else
        printf "%18s |%s| %s\n" "${timestamp}" "${version}" "${msg}" >> ${logfile}
    fi
}

function pick() {
    printf "Not implemented yet"
}

function set_tmux() {
    if [[ -n ${TMUX} ]]
    then
        title="${1}"
        session=${TMUX/,*}
        tmux -S ${session} rename-window "${title}"
    fi

}
function run_ssh_command() {
    check_sock
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${switch} ${server} "${command[@]}"
}

function run_ssh() {
    check_sock
    set_tmux ${server/.dap*}
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${server}
    ssh_result=$?
    set_tmux ${unset}
}

function check_sock() {
    csock=$(find /tmp -name 'agent*' -printf '%Ts %p\n' 2> /dev/null | sort | tail -n1 | cut -d' ' -f2)
    if [[ -z ${SSH_AUTH_SOCK} ]] || [[ ${csock} != ${SSH_AUTH_SOCK} ]]
    then
        printf "Renewing SOCK %s\n" "${csock}"
        export SSH_AUTH_SOCK=${csock}
    else
        printf "Sock not changed: %s\n" "${csock}"
    fi 
}

if [[ -n ${server} ]]
then
    if [[ -z ${command} ]]
    then
        run_ssh
    else
        run_ssh_command
    fi
else
  pick
fi
# set +x
