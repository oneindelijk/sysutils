#!/bin/bash
version=0.0
source ./property_reader.sh

load_vars main_config

function log(){
    printf "%-19s ÷ %s\n" "$(date '+%Y-%m-%d %T')" "${@}" >> whiplog.log
}

function menu(){
    menuname=${1}
    # load the variables from the file
    load_vars ${menuname}
    # use the itemlist from previous load to get the menu items from the file
    itemlistfile=.menu/${itemlist}.ilist
    #options=( "$(get_numbered_array ${itemlist})" )
    menuview=.menu/${itemlist}.view
    options=( "$(cat $itemlistfile)" )
    #pkgnum=${#options}
    #log "Found ${pkgnum} pkgs"
    [[ -z ${w_height} ]] && w_height=$((pkgnum + 6))
    [[ -z ${l_height} ]] && l_height=$((pkgnum + 1))
    [[ -z ${w_width} ]] && w_width=50
    
    # cmd=(dialog --column-separator "," --keep-tite --menu "${menuname}" 22 76 16)
    #cmd=(dialog --column-separator "," --menu "${menuname}" 22 76 16)
    cmd=(dialog --separator ","  --menu "${menuname}" 22 76 16)
    log "${cmd[@]}"
    log "${options[@]}"
    #choices=$("${cmd[@]}" "$(get_numbered_array ${itemlist})" 2>&1 >/dev/tty)
    #choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    choice=$("${cmd[@]}" $(cat ${itemlistfile} | awk -F"," '{print $1" "$2 }')} 2>&1 >/dev/tty)




}


# create menu file if it doesn't exists
new_property_file ${startup_menu_name} menu no
# start the main menu
menu ${startup_menu_name}
item=$(return_index_value ${itemlist} ${choice} )

printf "Chosen %s\n" "${item}"