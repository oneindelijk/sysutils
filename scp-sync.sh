#!/bin/bash

# script to watch a file or folder for changes and copy it to a remote destination

save_path=/home/sam/.config/scp_sync

function usage() {
    cat <<EOF
		Usage: autoscp2 [-x <n>]
		-x		redefine a script variable, where
		1) watch folder
		2) target server
		3) destination folder
		4) everything
EOF
}

function getargs() {
	#log "Switch: ${o}	${OPTARG}"
	unset wf_run
	while getopts ":svhxV" o; do
    case ${o} in
    x)
        case ${OPTARG} in
        1)
            unset watchfolder
            ;;
        2)
            unset wf_server
            ;;
        3)
            unset wf_dest
            ;;
        4)
            unset watchfolder
            unset wf_server
            unset wf_dest
            ;;
        esac
        ;;  
    s)  
        pick_from_options
        ;;
	*)
	    a_usage
	    wf_run=y
	    ;;
	esac
    done
}
function init_script() {
    [[ ! -d ${save_path} ]] && mkdir -p ${save_path}
}
function pick_from_options(){
    ls -1 ${save_path} > .tmps
    counter=0
    while read line
    do  
        printf "%-3s) %s\n" "${counter}" ${line}
        optionlist+=( ${line} )
    done < .tmps
    read -n 1 -s answer
    echo ${optionlist[$answer]}


}

function autoscp2() {
	# utility script that copies changed files to a chosen destination until ctrl-c is pressed
	unset wf_run
	a_usage(){
		
	}

    if [[ "$1" = "-x" ]] 
    then
	case $2 in
	1)
	    unset watchfolder
	    ;;
	2)
	    unset wf_server
	    ;;
	3)
	    unset wf_dest
	    ;;
	4)
		unset watchfolder
	    unset wf_server
	    unset wf_dest
		;;
	*)
	    a_usage
	    wf_run=y
	    ;;
	esac
	unset i2
    fi
    if [[ -z ${wf_run} ]]
    then
		[[ -z ${wf_server} ]] && printf "Server :" && read wf_server
		if [[ -z ${watchfolder} ]] 
		then 
			printf  "Folder:"
			read wf_tmp
			watchfolder=${wf_tmp}
		else
			printf "(Current Folder: %s) : " "${watchfolder}"
			read wf_tmp
			[[ ! -z $wf_tmp ]] && watchfolder=${wf_tmp}
		fi
		[[ -z ${wf_dest} ]] && printf "Remote destination :" && read wf_dest
		[[ -z ${wf_dest} ]] && wf_dest=.
		[[ -z ${autouser} ]] && autouser=schsup
		printf "Using var [autouser] -> %s. Use -x to reset\n%s\n" ${autouser} "watch ${watchfolder} ${autouser}@${wf_server}:${wf_dest}"
		while [ 0 ] 
		do 
			for tfile in "${watchfolder%\/}/"*
			do
				fname="${tfile//*\/}"
				statname="/tmp/${fname}.stat"
				# save current inode to a file and assign to i1
				i1=$(stat --printf "%Y" ${tfile})
				echo $i1 > "${statname}"
				# check if an 'old inode' file is around and assign the value to i2
				[[ -e "${statname}2" ]] && i2=$(cat "${statname}2")
				if [[ $i1 -ne $i2 ]]; then
					# inode are not the same; copy file to destination; copy i1 to i2
					i2=$i1;
					echo $i2 > "${statname}2"
					printf "The file %s has changed\n" "${fname}"
					# if the path ends with modules, save as .fn	
					if [[ ${tfile%\/*} =~ /modules$ ]] ; then
					    fn_name="${fname%\.*}"
					    destname="${fn_name}.fn"
						printf "%s is a module. Renaming to %s\n" "${fn_name:u}" "${destname:u}"
					else
						destname="${fname}"
					fi
                    if [[ !  "${wf_dest}" = "." ]]; then
                        destname="${wf_dest%\/}/${destname}"
                    fi
					scp "{tfile}" "${autouser}@${wf_server}:${destname}"
				fi





			done
			sleep 2
		done
    fi
}
init_script
getargs