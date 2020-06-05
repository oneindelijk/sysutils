#!/usr/bin/env python3
# 
import shutil
import getpass
import argparse
shutil.sys.path.append('/home/sam/Python/mods')
from my_system import run_cmd
# echo 1000 > /sys/class/backlight/intel_backlight/brightness
args=shutil.sys.argv

def usage():
    HELP='''
    usage: brightness [-h/<percentage>]

    -h              Show this Help
    <percentage>    Percentage to set brightness to
    '''
    print (HELP)

if getpass.getuser() != 'root':
    print('Run as root or with sudo !')
    shutil.sys.exit()
if len(args) != 2:
    print('Expected one argument')
    usage()
    shutil.sys.exit()

if args[1]=='-h':
    show_help()
else:
    try:
        percent=float(args[1])
    except:
        print('Error converting percentage: {}'.format(args[1]))
        shutil.sys.exit()

try:
    mx=run_cmd('cat /sys/class/backlight/intel_backlight/max_brightness')[0]
    cur=run_cmd('cat /sys/class/backlight/intel_backlight/actual_brightness')[0]
except:
     print('Error getting max brightness')
     shutil.sys.exit()
else:
    try:
        maxBrightness=float(mx)
    except:
        print('Error converting max: {}'.format(mx))
        shutil.sys.exit()
    else:
        print('Current Brightness: {}'.format(cur))
newBrightness = maxBrightness * percent/100
print('New Brightness: {}'.format(newBrightness))
cmd='echo {} > /sys/class/backlight/intel_backlight/{}'.format(newBrightness,'brightness')
run_cmd(cmd)

