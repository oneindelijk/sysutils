#!/bin/bash
version=" L
0.3"
# try to fix usb network connection at boot for bananapi h2+

function get_info() {
    printf "Version = %s\n" "$version"
    ip l
    ip a show dev usb0
    ip r
    ping 192.168.3.150
}

function bring_usb_if_up() {
    ip l set up dev usb0
}

function set_ip(){
    ip a add 192.168.3.7/24 dev usb0
}

function make_rev_ssh() {
    ssh -i /root/.ssh/id_rsa -fN -R 9999:localhost:22 sam@192.168.7.150  
}
function backup_logs() {
    [[ -e /root/startup_script.log ]] && cp /root/startup_script.log$(ls -l /root | grep startup_script.log | wc -l)
    [[ -e /root/startup_info.log ]] && cp /root/startup_info.log$(ls -l /root | grep startup_info.log | wc -l)
}
backup_logs
printf "%s\n" "$(date)" &> /root/startup_script.log 
get_info &> /root/startup_info.log 
sleep 5
printf "%s\n\n" "$(date)" &> /root/startup_script.log 
get_info &> /root/startup_info.log 
make_rev_ssh &> /root/startup_script.log 

printf "%s\n\n" "---------" &>> /root/startup_script.log 