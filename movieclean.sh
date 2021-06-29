#!/bin/bash
version="0.0.32"

# copy finished mp4 from timelapse to host snifer
# systemd will run this service with a systemd timer

# changelog

source_moviefolder=/home/pi/.octoprint/timelapse
destination_host=snifer
destination_moviefolder=Videos/timelapse
ssh_user=sam

function check_host_up() {
    ping -c 1 ${destination_host} > /dev/null
    if [ $? -eq 0 ]
    then 
        return 0
    else
        return 1
    fi
}

function have_movies() {
    find -L ${source_moviefolder} -type f -iname '*.mp4' -not -name '.*' -mmin +5 > /tmp/.movielist
    if [[ $(cat /tmp/.movielist | wc -l) -gt 0 ]]
    then 
        return 0
    else
        return 1
    fi
}

function transfer_movies() {
    while read movie
    do  
        scp ${movie} ${ssh_user}@${destination_host}:${destination_moviefolder}
        if [[ $? -eq 0 ]]
        then    
            rm -v ${movie}
        else
            printf "Error copying ${movie} to ${destination_host}:${Videos}\n"
        fi


    done < /tmp/.movielist
}

if $(check_host_up)
then
    if $(have_movies)
    then
        printf "Script version: $version"
        transfer_movies
    fi
else
    printf "Host is down\n"
fi
