#!/bin/bash
#disabling main for testing
sed -i 's:^main$:\#-main:g' ssh_helper.sh
source ssh_helper.sh
# enable main again
sed -i 's:^\#-main$:main:g' ssh_helper.sh
#verbose=yes

function random(){
    upper=$1
    rand=$(head -c 500 /dev/urandom | tr -dc '0-9' | fold -w ${#upper} | head -n 1)
    rnd=$((rand % upper))
    echo $rnd
}

function pick_rnd(){
    list=( ${@} )
    list_len=${#list[@]}
    idx=$(random ${list_len})
    val=${list[${idx}]}
    # log picked $idx from listlen ${list_len} : ${val}
    echo ${val}
}

function test_update() {
    for srv in ${test_servers[@]}
    do
        field=$(pick_rnd ${test_fields[@]} )
        value=$(pick_rnd ${test_values[@]} )
        printf "Updating ${srv} ${field} ${value}\n"
        update ${srv} ${field} ${value}

    done

}
function test_get_values(){
    for srv in ${test_servers[@]}
    do
        printf "%-25s\n" ${srv} 
        for fieldName in ${test_fields[@]}
        do
            [[ -n ${verbose} ]] && set -x   
            value=$(get_value ${srv} ${fieldName})
            [[ -n ${verbose} ]] && set +x
            if [[ -n ${value} ]]
            then
                printf "    %-25s %-15s\n" ${fieldName} "${value}"
            else
                emptyc+=( ${fieldName} )
            fi
        done
        emptystr="${emptyc[@]}"
        printf "Variables with no value: %s\n" "${emptystr}"
        emptyc=
    done
}
function test_get_next_user() {
    userlen=${#USERS[@]}
    user=${USERS[0]}
    while [[ $i -lt $((userlen + 1 )) ]]
    do
        printf "%s %s %s\n" "$i" "$user" "$(get_next_user ${user})"
        user=$(get_next_user ${user})
        i=$((i+1))
    done
}
function test_random() {
    test_list=( een twee drie vier vijf zes 7 8 9 10 11 12 13 14 15 16 )
    for t in  1 2 3 4 5 6 7 8 9 10 11
    do
        printf "%s " ${t}

        pick_rnd ${test_list[@]} 
    done

}
# test_servers=( testserver1 testAserver1 testserverA ) # testserver3 BHOST-3 B_Host )
test_servers=( $(cat ${cfg} | cut -d';' -f1) ) # testserver3 BHOST-3 B_Host )
test_fields=( user id_key port index last_result last_user )
test_values=( val1 VALA value true 0 344 k-l04 bromium-4 de_jeff /var/log vOOl13 VrLr vOOluu truu 03 334343 k-l0343 bromium-43 du_juff /vOOr/log )
# test_update
test_get_values
test_get_next_user    













