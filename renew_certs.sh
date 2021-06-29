#!/bin/bash
version="0.2.0"
certfile=signed-cert.pub
sbxcertfile=signed-cert-sbx.pub
local_certfile_path=$HOME/.ssh/$certfile
local_sbx_certfile_path=$HOME/.ssh/$sbxcertfile
certfile_on_client=signed-cert-prd.pub
sbx_certfile_on_client=signed-cert-sbx.pub
cert_treshhold_age=43200
prd_port=22003
sbx_port=22002
bastion_prod=prdjump
bastion_sbx=sbxjump

function usage() {
    help=""" ${0} [-f]
    Check age of certificate file and renew if more than 12 hours
    -f      force renewal, regardless of age
    """
    printf "${help}"

}

function check_cert_age(){
    # use installed version of stat, instead of builtin, which is not working
    [[ $(which stat) =~ *aliased* ]] && unalias stat
    mtime=$(stat -c '%Y' $local_certfile_path)
    if [[ $((mtime + cert_treshhold_age)) -lt $(date +%s) ]]
    then
        printf "Certfile expired\nExecute sign_pub_key (sk) and enter password + ENTER + CTRL-D"
        ssh -p ${prd_port} ${bastion_prod}
        printf "Well done ! Do this again !!"
        ssh -p ${sbx_port} ${bastion_sbx}
        scp -P ${prd_port} ${bastion_prod}:.ssh/${certfile} ${local_certfile_path}
        scp -P ${sbx_port} ${bastion_sbx}:.ssh/${certfile} ${local_sbx_certfile_path}
        if [[ $(hostname) != snifer ]]
        then
            scp ${local_certfile_path} sam@snifer:.ssh/${certfile_on_client}
            scp ${local_sbx_certfile_path} sam@snifer:.ssh/${sbx_certfile_on_client}
            ssh sam@snifer "sudo chmod -v 600 .ssh/${certfile_on_client}"
            ssh sam@snifer "sudo chmod -v 600 .ssh/${sbx_certfile_on_client}"
        else
            sudo chmod -v 600 .ssh/${certfile_on_client}
            sudo chmod -v 600 .ssh/${sbx_certfile_on_client}
        fi
    fi
}
printf "Version %s\n" "${version}"
if [[ -z $1 ]]
then
    check_cert_age
else
    if [[ ${1} == -f ]]
    then
        printf "Forcing renewal\n"
        rm ${local_certfile_path}
        check_cert_age
    else
        usage
    fi

fi
# tunnel is set up through mobaxterm

