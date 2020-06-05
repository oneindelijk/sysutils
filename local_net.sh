#!/bin/bash
declare -a adapters
pointer_dir=~/.pointers
active_adapter_pointer=${pointer_dir}/localnet_default_adapter
# figure out ip address
function init(){
    [[ ! -d ${pointer_dir} ]] && printf "Creating dir %s\n" ${pointer_dir} && mkdir -p ${pointer_dir} 

}

function filtered_adapters(){
    omit_adapters=( lo tun0 )
    ip -br a | awk '{print $1}' | while read adapter
    do
        if [[ ! ${omit_adapters[@]} =~ ${adapter} ]]
        then
          printf "%s\n" ${adapter}
        fi
    done

}
function get_ip(){
    target=$1
    ip -br a |  sed -ne '/'"${target}"'/ s:.*\ \([[:digit:].]\+\)\/.*:\1:p'
}
function get_subnet(){
    target=$1
    IPADDRESS=$(get_ip $1)
    MASK=$(ip -br a |  sed -ne '/'"${target}"'/ s:.*\ \([[:digit:].]\+\)\/\([[:digit:]]\+\)\ .*:\2:p')
    printf "%s.0/%s\n" ${IPADDRESS%\.*} ${MASK}
}
# pick default
function pick_adapter() {
    if [[ -e ${active_adapter_pointer} ]] 
    then
        ACTIVE_ADAPTER=$(cat ${active_adapter_pointer})
    fi
    if [[ -z ${ACTIVE_ADAPTER} ]]
    then
        [[ -z ${ADAPTERS} ]] && ADAPTERS=$(filtered_adapters)
        ACTIVE_ADAPTER=${ADAPTERS[0]}
        printf "%s\n" ${ACTIVE_ADAPTER} > ${active_adapter_pointer}
    fi
}
# refresh
init
pick_adapter
printf " *  %s\n" ${adapters[@]}
for i in ${adapters[@]}
do
    get_ip $i
    get_subnet $i
done
#echo "${get_ips[@]}" 