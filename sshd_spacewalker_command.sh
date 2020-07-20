#!/bin/bash
version="0.1.24"
sshcfg=/etc/ssh/sshd_config

function show_info() {
    printf "Script Version\n%s\n\n" $version
    printf "\nroot authorized_keys files\n-------------------\n"
    find /root -name 'authorized_keys*'
    printf "\nsshd_config\n-------------------\n"
    cat -n ${sshcfg} | grep -C2 -e 'authorized\|Match'
    printf "\nservice sshd Status\n-------------------\n"
    service sshd status
    service sshd restart
    service sshd status
    printf "\nservice openvpn Status\n-------------------\n"
    service openvpn status
    printf "\nIP CONFIG\n-------------------\n"
    ip a
    printf "\nNETWORK\n-------------------\n"
    # tcptraceroute sus.schaubroeck.be 4900
    ss -anp | grep -e 'sshd'
    iptables -L -v
    printf "\nauthorized_keys\n-------------------\n"
    find /home/ -name 'authorized_keys*' -ls
    printf "\nmessages\n-------------------\n"
    tail -n 40 /var/log/messages
}


if [[ $(grep -e '^AuthorizedKeysFile.*.ssh/authorized_keys2$' ${sshcfg} > /dev/null; echo $? ) -ne 0 ]]
then
    awk '{print} /AuthorizedKeysFile/ && !n {print "AuthorizedKeysFile\t.ssh/authorized_keys2"; n++}' ${sshcfg} > tmpcfg
    sshd -t -f tmpcfg
    if [[ $? -eq 0 ]] 
    then
        cp tmpcfg ${sshcfg} 
    else
        printf "%s\n" "Error Validating tmpcfg"
        cat tmpcfg
    fi
fi

if [[ $(grep -e '^AuthorizedKeysFile.*\ \./authorized_keys2$' tmpcfg > /dev/null; echo $? ) -eq 0 ]]
then
        printf "Removing erroneous sshd_entry\n"
        sed '/\.\/authorized_keys/d' ${sshcfg} > tmpcfg
fi  
sshd -t -f tmpcfg
if [[ $? -eq 0 ]] 
then
        cp tmpcfg ${sshcfg} 
else
        printf "%s\n" "Error Validating tmpcfg"
        cat tmpcfg
fi

show_info