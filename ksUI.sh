#!/bin/bash
searchstr=${@}

function usage(){
    printf "   %s\n" "usage: $0 <search>"
}

[[ -z ${searchstr} ]] && usage && exit 0
my_shm_file="/dev/shm/$USER-${0/*\/}"
touch "${my_shm_file}"
#declare -a pkg
# pikaur -Ssq ${searchstr} | nl > "${my_shm_file}"
function try_separately(){
    
    for pkg in ${choices[@]}; do
        pikaur -S --noconfirm ${pkg}
    done
}
#pkg=( $(pikaur -Ssq ${searchstr[@]} | awk '{print $1 " on"}') )
pkgnum=${#pkg}
title="Found ${pkgnum} pkgs"
w_height=$((pkgnum + 6))
l_height=$((pkgnum + 1))
w_width=50
menu="Select the packages you want to install(arios saflarius)"
mcmd=(dialog --stdout --no-items --separate-output --checklist "Select options:" $w_height $w_width $l_height )
#choices=$("${mcmd[@]}" ${pkg})
choices=$(dialog --stdout --no-items --separate-output --checklist "${menu}" 40 50 35 $(pikaur -Ssq ${searchstr[@]} | awk '{print $1 " off"}'))
#dialog --stdout --no-items --separate-output --checklist "r" 40 50 35 $(pikaur -Ssq ${searchstr} | awk '{print $1 " off"}')
#printf "%s\n" "${title}"
#printf "%s\n" "${pkg[@]}"
selpkg=${#choices[@]}
if [[ ${#selpkg} -gt 0 ]]; then
    printf "Installing %s packages.\n" "${selpkg}"
    printf "%s\n" "${choices[@]}"
    pikaur -S --noconfirm ${choices[@]}
    [[ $? -ne 0 ]] && try_separately
fi

