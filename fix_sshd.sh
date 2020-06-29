#!/bin/bash
(version="0.0.20"

function get_line_number(){
    # return line numbers from entries that are not commented and contain searchexp
    searchexp=$1
    while read line
    do
        if [[ $line =~ $searchexp ]]
        then
            if [[ ! $line =~ \# ]]
            then
                echo ${line} | sed -ne 's: *\([0-9]\+\)\ .*:\1:p'
            fi
        fi
    done < ~/.sshd1
}

function reposition_line() {
    # delete line
    echo Deleting line with authorized_keys2
    sed -i '/AuthorizedKeysFile.*authorized_keys2/d' ${sshcfg}
    if [[ -n ${keys_disabled} ]]
    then    
        echo Adding new line to tempfile
        awk '{print} /AuthorizedKeysFile/ && !n {print "AuthorizedKeysFile\t.ssh/authorized_keys2"; n++}' ${sshcfg} > tmpcfg
    fi

}
# make backup
backup=/home/schsup/sshd_config_backup_$(date "+%Y-%m-%d_%H-%M")
sshcfg=/etc/ssh/sshd_config
cp -v ${sshcfg} ${backup}
cat -n ${sshcfg} | grep 'authorized_keys\|Match\ User' > ~/.sshd1
function validate_and_apply() {
    sshd -t -f tmpcfg
    if [[ $? -eq 0 ]] 
    then
       echo Validation succesfull. copying tmpcfg to ${sshcfg} 
       cp tmpcfg ${sshcfg} 

    fi
    if [[ $(service sshd status > /dev/null ; echo $?) -ne 0 ]]
    then
        service sshd start
    fi
}
# do checks
[[ $(grep -e '^\#AuthorizedKeysFile.*.ssh/authorized_keys$' ${sshcfg} > /dev/null; echo $? ) -eq 0 ]] && keys_disabled=1 || echo disabled authorized_keys not present
[[ $(grep -e '^AuthorizedKeysFile.*.ssh/authorized_keys$' ${sshcfg} > /dev/null; echo $? ) -eq 0 ]] && keys_enabled=1 || echo authorized_keys not present
[[ $(grep -e '^\#AuthorizedKeysFile.*.ssh/authorized_keys2$' ${sshcfg} > /dev/null; echo $? ) -eq 0 ]] && keys2_disabled=1 || echo disabled authorized_keys2 not present
[[ $(grep -e '^AuthorizedKeysFile.*.ssh/authorized_keys2$' ${sshcfg} > /dev/null; echo $? ) -eq 0 ]] && keys2_enabled=1 || echo authorized_keys2 not present

if [[ -n ${keys2_enabled} ]]
then
    keys_line=$(get_line_number .ssh/authorized_keys2)
    match_line=$(get_line_number Match)
    if [[ ${keys_line} -gt ${match_line} ]]
    then
        reposition_line
        validate_and_apply
    fi

fi
) > /home/schsup/fix_sshd_cfg.log