#!/bin/bash
source 

function check_pulse() {
    pulse=$(pulseaudio --check)
    if $pulse;
    then
        state="${ORANGE}YES${WHITE}"
    else
        state="${GREEN}NO${WHITE}"
    printf "%40s %s" "Pulse Daemon Running:" "${state}" 

}