#!/bin/bash
version="0.4"
# try to fix usb network connection at boot for bananapi h2+

function log () {
    msg=${@}
    printf "%18s %s\n" "$(date)" "${msg}" >> /root/startup_script.log
}

function get_info() {
    printf "\nVersion = %s\n" "$version"
    log "IP INFO"
    log "_______"
    log $(ip l show dev usb0)
    log $(ip a show dev usb0)
    log $(ip r)
    log $(ping 192.168.7.150)
    log $(cat /etc/resolv.conf)
}

function bring_usb_if_up() {
    log "Trying to bring usb0 up..."
    ip l set up dev usb0 >> /root/startup_script.log
}

function set_ip(){
    log "Setting IP For usb0"
    ip a add 192.168.7.3/24 dev usb0 >> /root/startup_script.log
}

function make_rev_ssh() {
    log "Setting up reverse tunnel"
    ssh -i /root/.ssh/id_rsa -fN -R 9999:localhost:22 sam@192.168.7.150  >> /root/startup_script.log
}
function backup_logs() {
    [[ -e /root/startup_script.log ]] && cp -v /root/startup_script.log /root/startup_script.log$(ls -l /root | grep startup_script.log | wc -l)
    [[ -e /root/startup_info.log ]] && cp -v /root/startup_info.log /root/startup_info.log$(ls -l /root | grep startup_info.log | wc -l)
}
function checks() {
    state=$(ip l show dev usb0 | grep DOWN > /dev/null; echo $?)
    log "STATE: $state"
    [[ ${state} -eq 0 ]] && bring_usb_if_up
    ipaddress=$(ip a show dev usb0 | grep 192.168.  > /dev/null; echo $?)
    log "IPADDRESS: $ipaddress"
    [[ ${ipaddress} -eq 0 ]] && set_ip
}

log "Script Start"
backup_logs 
get_info
sleep 15

checks
make_rev_ssh
get_info
log "-------------------------------" 