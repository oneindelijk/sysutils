#!/bin/bash

version='1.8'
logfile=/var/log/schaubroeck/chmod_fixer.log
debug=true
workingdir=/home/schsup/chmodfix
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

function list_home_users(){
    ls -1 /home > /tmp/home_users
    while read usr
    do 
        if [[ $(id $usr > /dev/null; echo $?) -eq 0 ]]
        then
            # is valid user
            if [[ $usr != 'schsup' ]]
            then
                fix_perms $usr
            else
                log skipping $usr
            fi
            usrlog=${workingdir}/$usr
        fi
    done < /tmp/home_users
}

function fix_perms() {
    target=${@}
    log Fixing permissions for $target
    chown -Rv ${target} /home/${target} > ${usrlog}_chown.log
    chmod -Rv 755 /home/${target} > ${usrlog}_chmod.log
    
    [[ -e /home/${target}/.ssh ]] && chmod -Rv 700 /home/${target}/.ssh >> ${usrlog}_chmod.log
    [[ -e /home/${target}/.ssh/id_rsa ]] && chmod 600 /home/${target}/.ssh/id_rsa >> ${usrlog}_chmod.log
    [[ -e /home/${target}/.ssh/authorized_keys ]] && chmod 644 /home/${target}/.ssh/authorized_keys >> ${usrlog}_chmod.log
    
    
}
[[ ! -d ${workingdir} ]] && mkdir ${workingdir}
list_home_users
