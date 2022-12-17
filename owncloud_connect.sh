#!/bin/bash
version="0.1"
if [[ $(ps aux | grep ssh | grep -v grep | grep 5050 > /dev/null;echo $?) -ne 0 ]]
then
    printf "%s\n" "No connection detected. Trying to connect..."
    ssh -fN -R 5050:localhost:22 -p 10023 owncloud.shor.ch
    if [[ $(ps aux | grep ssh | grep -v grep | grep 5050 > /dev/null;echo $?) -ne 0 ]] 
    then
         printf "%s\n" "Connection NOT restored"
         connstat=Failed
    else
        connstat=Restored
    fi
else
    connstat=Active
    ssh -p 10023 owncloud.shor.ch 'printf "%s Connection %s\n" "$(date)" "${connstat}" >> skull.log' 
fi

printf "%s Connection %s\n" "$(date)" "${connstat}" >> /var/log/owncloud_connect.log
