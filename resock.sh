#!/bin/bash
csock=$(find /tmp -name 'agent*' -printf '%Ts %p\n' 2> /dev/null | sort | tail -n1 | cut -d' ' -f2)
if [[ ${csock} != ${SSH_AUTH_SOCK} ]]
then
	printf "Renewing SOCK %s\n" "${csock}"
	export SSH_AUTH_SOCK=${csock}
fi

