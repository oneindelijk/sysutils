#!/bin/bash
# awesome pavucontrol helper
# kills pavu if it is already open and (re)launches it under the cursor

[[ $(ps -ax | grep -v grep | grep pavucontrol > /dev/null; echo $?) -eq 0 ]] && pkill pavucontrol
pavucontrol &
