#!/bin/bash
server=$1
version="2.1"
lang=nl
forgot_server_en="Did you forget to add a server ?"
forgot_server_nl="Is de server opgegeven ?"
fg_n=forgot_server_${lang}
forgot_server="${!fg_n}"
cfg=~/.config/ssh_users
logfile=~/log/ssh_helper.log
USERS=( schsup sam svk foreman root ansible_user rescue )
unset='·'
list_sep='¸'

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
function set_tmux() {
    title="${@}"
    tmux -S /tmp/tmux-1000/default rename-window $title

}
function get_index(){
    # The index correlates to the last succesfull user the server connected with from USERS
    srv=$1
    idx=$(sed -ne '/^'"$srv"';/ s:.*\ index=\([0-9]\+\).*:\1:p' ${cfg})
    if [[ -z ${idx} ]]
    then
        echo 0
    else
        echo ${idx}
    fi
}
function check_server() {
    srv=$1
    if [[ -z $(grep "^${srv};" ${cfg} ) ]]
    then
        printf "%s;\n" "${srv}" >> ${cfg}
        log "==> Added new server ${srv}"
    # else
        # log Server ${srv} found in db

    fi
    
}
function get_value(){
    srv=$1
    shift
    gv_fieldName=$1 
    check_server ${srv}
    present=$(grep "^${srv};" ${cfg} | grep "${list_sep}${gv_fieldName}=" )
    if [[ -z ${present} ]]
    then
        value=""
    else
        value=$(sed -ne '/^'"$srv"';/ s:.*'"${list_sep}${gv_fieldName}"'=\([[:alnum:].]\+\)'${list_sep}'*.*:\1:p' ${cfg})
    fi
    echo ${value}
}

function update(){
    srv=$1
    shift
    up_fieldName=$1
    shift
    value="${@}"
    check_server ${srv}
    present=$(grep "^${srv};" ${cfg} | grep "${list_sep}${up_fieldName}=" )
    if [[ -z ${present} ]]
    then
        # insert new up_fieldName
        log "-> inserting new field ${up_fieldName} for server ${srv} with value ${value}"
        sed -i '/^'"$srv"';/ s:\(.*\):\1'"${list_sep}${up_fieldName}"'='"$value"':g' ${cfg}
    else
        # replace field with value
        log " ^ update existing field ${up_fieldName} for server ${srv} with value ${value}"
        sed -i '/^'"$srv"';/ s:'"${list_sep}${up_fieldName}"'=[[:alnum:][:punct:]]\+:'"${list_sep}${up_fieldName}"'='"$value"':g' ${cfg}
    fi
}
function run_ssh() {
    set_tmux ${server}
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${user}@${server}
    ssh_result=$?
    log_results
    set_tmux ${unset}
}

function get_next_user(){
    current=$1
    ind=0
    for usr in ${USERS[@]}
    do
        if [[ ${usr} = ${current} ]]
        then    
            if [[ ${ind} -lt ${#USERS[@]} ]]
            then
                next_user=${USERS[$((ind + 1))]}
                echo ${next_user}
            # else
            #     # end of list
            #     echo 0
            fi

        fi
        ind=$((ind + 1))
    done

}
function log_results(){
    update ${server} last_try $(date '+%F')
    if [[ ${ssh_result} -eq O ]] 
    then
        # success update file
        log connecting succeeded
        update ${server} index ${index}
        update ${server} user ${user}
        update ${server} last_result 0
        update ${server} last_user ${user}
    else    
        log ssh ended ${server} error ${ssh_result}
        #printf "Error in ssh\n"
        update ${server} index $((index + 1))
        update ${server} fail $((fail + 1))
        update ${server} last_result ${ssh_result}
    fi
}

function test_ssh() {
    ceol=$(tput el)
    log "<< running ssh  ${user}@${server} ls . >>"
    printf "\033[1K"
    printf "\rTrying with ${user}"
    ssh_result=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=1 ${user}@${server} ls &> /dev/null;echo $?)
    log_results
}
function main(){
    [[ -z ${server} ]] && printf "%s\n" "${forgot_server}" && exit 1
    user=$(get_value ${server} user)
    log "===== SSH Helper :: ${version} ::"
    index=$(get_index ${server})
    [[ -z ${user} ]] && user=${USERS[${index}]}
    set_tmux ${server}
    last=$(get_value ${server} last_result)
    while [[ ${last} != 0 ]]
    do  
        log Testing with ${user}@${server}
        test_ssh
        last=$(get_value ${server} last_result)
        if [[ $last -ne 0 ]]
        then
            user=$(get_next_user ${user})
            log Got next user ${user}
            if [[ -z $user ]]
            then
                printf "\nTried all users\n"
                update ${server} user ${USERS[0]}
                exit 1
            fi
        fi
    done
    run_ssh
    
}
main

