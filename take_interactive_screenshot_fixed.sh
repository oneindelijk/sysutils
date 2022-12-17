#!/bin/bash
tgt="/home/sam/ScreenShots/Fixed/screenshot $(date +'%a %e %b %Y %Uu%Ms%Ss').png"
if [[ -z $1 ]]
then
	import -extent '800x320>' -gravity Center "${tgt}"
	notify-send "Screenhsot saved as ${tgt}"
else
	scrot ${tgt}
	notify-send "Full-screen Screenhsot saved as ${tgt}"
fi
