#!/bin/bash
jump_user=svk 
jump_server=gemgtjumphost.vm.cipal.net
srv=$1
function geelsrvlookup() {
   
    ip=$(grep -iF ${srv} /home/sam/Documenten/scriptlookup/hostsgeel | awk '{print $1}')
}

function usage() {
    cat <<EOF
  Usage: 
      geeljump.sh [-abvrp] [-s scp_file] server
      geeljump.sh -h

  Login to <server> using jumphost

    server         The server you want to login or copy to
    -s scp_file    The file you want to copy to the server (COPY MODE)
    -p             show ip address and exit
    -a             login as csadmin
    -b             login as cipadmin
    -r             login as root
    -v             Be verbose
    -h             Show this help and exit

  The argument <server> is mandatory

  For bug reporting, please contact:
  <sam.vankerckhoven@cipalschaubroeck.be>.
EOF
}
function css(){
    ssh -J ${jump_user}@${jump_server} ${jump_user}@$1
    if [ $? -ne 0 ]
    then
  geelsrvlookup
  
    fi
}
function csr(){
    ssh -J ${jump_user}@${jump_server} root@$1
    if [ $? -ne 0 ]
    then
    geelsrvlookup
    ssh -J ${jump_user}@${jump_server} root@ip
  fi
}
function lookupByName() {
    hostname=$1
    ssh ${jump_user}@${jump_server} "nslookup ${hostname}" > .nslookup
    if [[ $? -eq 0 ]]
    then
  ipaddress=$(grep -A1 Name .nslookup | sed -ne 's:.*\ \([0-9\.]\):\1:p')
  echo ${ipaddress}
    fi
    rm .nslookup 
}
function custom_action() {
    case ${ACTION} in
    show_ip)
  ip=$(lookupByName ${srv})
  printf "Server %s has IPADDRESS: %s\n" "${srv}" "${ip}"
  exit 0
  ;;
    scp)
  printf "Secure copy not implemented yet\n"
  exit 0
  ;;
    esac

}

function getargs() {
    while getopts "vprabhs:" o; do
  #log "Switch: ${o}  ${OPTARG}"
      case "${o}" in
        v)
          set -x
          VERBOSE=true
          ;;
        r)
          user=root
          ;;
        a)
          user=csadmin
          ;;
        b)
          user=cipadmin
          ;;
        h)
          usage
        exit 0
          ;;
        p)
          ACTION=show_ip
          ;;
        s)
          ACTION=scp
          FILE=${OPTARG}
          ;;
        *)
          echo ${OPTARG}
          ;;
      esac
    done
}
user=${jump_user}
getargs "${@}"
srv=${@:$OPTIND:1}
if [[ -z ${ACTION} ]] 
then
    geelsrvlookup
else
    custom_action
fi

if [ ! -z ${ip} ]
then
    printf "Found %s for %s\n" "${ip}" "${srv}"
    printf "Connecting %s with %s\n" "$ip" "$user"
    if [[ -z ${VERBOSE} ]]
    then
  ssh -J ${jump_user}@${jump_server} $user@$ip
    else
  ssh -vv -J ${jump_user}@${jump_server} $user@$ip
    fi
else

    printf "Connecting %s with %s\n" "$srv" "$user"    
    if [[ -z ${VERBOSE} ]]
    then
  ssh -J ${jump_user}@${jump_server} $user@$srv
    else
  ssh -vv -J ${jump_user}@${jump_server} $user@$srv
    fi
fi
set +x
