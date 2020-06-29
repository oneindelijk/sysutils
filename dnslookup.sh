#!/bin/bash

#lookup names/ips in the DNS
# original version in /home/sam/sysutils
napoleon=193.74.195.19
ssh_key=/home/ansible/.ssh/idrsa_schsup
version="1.0.6"
function usage() {
    cat <<EOF 
	Usage: $0 [OPTIONS] searchpattern
	Version: ${version}

	Inquire napoleon for all hosts that match [searchpattern]

	OPTIONS:
	
	  -a	   perform a nslookup from dns server and display ip address
	
	  
	For bug reporting instructions, please contact:
	<sam.vankerckhoven@cipalschaubroeck.be>.
EOF
}

function list_ips() {
    exec {FD}< .nsl
    while read -u ${FD} line
    do
	ip=$(ssh -i ${ssh_key} root@${napoleon} "nslookup ${line}" | sed -ne '/Name:/,$ s:.*Address\:\ \(.*\):\1:p')
	printf "  %-29s%18s\n" "${line}" "${ip}"
    
    done 
    exec {FD}<&-
}

function get_hosts(){
  ssh -i ${ssh_key} root@${napoleon} 'grep "'${searchstr}'" netwerk/*' | grep -v hinfo | sed -ne 's:[a-z\/\.0-9\-]\+\:\([a-z]\+\)\ .*:\1:p' | sort | uniq > .nsl
}

function list_simple_hostnames(){
  cat .nsl  
}

if [[ ${#@} -eq 2 ]] 
then
    if [[ "$1" = "-a" ]]
    then	
	# also lookup address
	lookup=yes
    else
	usage
	exit 1
    fi
    shift 
fi
searchstr=$1
# loc=
get_hosts

if [[ $lookup = "yes" ]]
then
    list_ips
else
    list_simple_hostnames
fi

#~ #!/bin/bash
#~ FILENAME="my_file.txt"
#~ exec {FD}<${FILENAME}     # open file for read, assign descriptor
#~ echo "Opened ${FILENAME} for read using descriptor ${FD}"
#~ while read -u ${FD} LINE
#~ do
    #~ # do something with ${LINE}
    #~ echo ${LINE}
#~ done
#~ exec {FD}<&- 
