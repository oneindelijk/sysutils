#!/bin/bash

imghost=192.168.3.46
ssh_user=sam
ssh_key=/home/sam/.ssh/id_rsa
imglocation=Pictures/varia
[[ -n $1 ]] && imglocation="Pictures/${1}"
camoptions="-ex backlight -awb auto -rot 180"


function take_a_picture(){
	image="/shares/images/image-$(date "+%y%m%d-%H%M").png"
	printf "Saving picture to %s\n" "${image}"
	/opt/vc/bin/raspistill -o $image ${camoptions} 
	chmod 777 $image
	chown sam: $image
	
}

function take_a_lab_picture(){
	parm=$1
	image="/shares/images/image-${parm}-$(date "+%y%m%d-%H%M").png"
	printf "Saving picture to %s\n" "${image}"
	/opt/vc/bin/raspistill -o $image -awb ${parm} 
	chmod 777 $image
	chown sam: $image
	
}
function test_ssh() {
	ssh -o ConnectTimeOut=1 -i ${ssh_key} ${ssh_user}@${imghost} 'hostname' > /dev/null
	return $?
}
function send_to_host() {
 	for png in /shares/images/*.png
        do
	   printf "Copying %s\n" ${png}
           scp -o ConnectTimeOut=20 -i ${ssh_key} ${png} ${ssh_user}@${imghost}:${imglocation}  
           if [[ $? -eq 0 ]]
           then 
                rm $png
           fi 
        done
	printf "Copy Finished\n"
}
function check_dir() {
    path="${1}"
    marker=".${path/\//_}"

    [[ ! -e $marker ]] && ssh -o ConnectTimeOut=1 -i ${ssh_key} ${ssh_user}@${imghost} mkdir ${path}
    touch $marker
}

function test_awb() {

	for test in off auto sun cloud shade tungsten fluorescent incandescent flash horizon greyworld
	do
		take_a_lab_picture ${test}
		sleep 1
	done
}
if [[ $(test_ssh) -eq 0 ]]
then
    check_dir "$imglocation"
	take_a_picture
else
	printf "host: ${imghost} not ready\n" >> /home/sam/log/cron_picture.log
fi


#test_awb
send_to_host
