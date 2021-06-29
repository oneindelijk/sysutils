#!/bin/bash
source ~/sysutils/term_colors.sh
# show_dns_recs

dnsserver=labo
raw_results=~/tmp/dns_dril_results_raw
saved_results=~/tmp/dns_dril_results
temp_results=~/tmp/dns_temp_results

ssh $dnsserver drill axfr blue.tesla-intergalactic.org > ${raw_results}
while read line
do
    read -a lineArray <<< ${line}
    if [[ ${lineArray[2]} == IN ]]
    then  
        ipaddress="${lineArray[4]}"
        if [[ ${ipaddress} =~ ^192 ]]
        then
            fqdn="${lineArray[0]}"
            hostname=${fqdn%%.*}
            if grep "$line" ${saved_results} > /dev/null
            then
                hostcolor=${Yellow}
                ipcolor=${Green}
            else
                hostcolor=${BYellow}
                ipcolor=${BGreen}
            fi
            printf "${ipcolor}%-18s${hostcolor}%s\n" "${lineArray[4]}" "${hostname}"
        fi
    fi

done < ${raw_results}
mv ${raw_results} ${saved_results}