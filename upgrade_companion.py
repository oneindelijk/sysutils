#!/usr/bin/env python3
"""
  -- upgrade_companion --

  Path: ~/sysutils/upgrade_companion.py
  BY: Sam Van Kerckhoven <sam.vankerckhoven@cipalschaubroeck.be> 
  Created: Wed 09 Sep 2020

  Purpose: Check the output of the expect script and take corrective measurements

"""
import shutil
import time
home = shutil.os.environ['HOME']
modpath = shutil.os.path.join(home, 'myPython/mods')
shutil.sys.path.append(modpath)
from my_system import run_cmd, run_bg_cmd, prit

# variables

expect_script = '/home/sam/systemen/systemen/intern/expect/pikaur_wrapper.expect'
expect_output = '/home/sam/log/pikaur_wrapper-expect.log'

def check_run():
    command = "ps ax | grep -v grep | grep -e 'expect'"
    result, error, code = run_cmd(command)
    if code == 0:
        return True
def launch_expect():
    command = '/usr/bin/expect {}'.format(expect_script) #, expect_output)
    run_bg_cmd(command, expect_output, expect_output)
    print("Launched: {}".format(command))

launch_expect()
while check_run():
    # waiting for expect to finish
    time.sleep(5)
    prit('=')
print()
print('expect has exited !')