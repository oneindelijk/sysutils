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
started = None
timeouts = 0
def check_run_time():
    # set starting time when not set
    if started == None:
        started = time.time()
    if time.time() - started > 30*60:
        timeouts ++
        started = time.time()
        return True

def check_run():
    command = "ps ax | grep -v grep | grep -e 'expect'"
    result, error, code = run_cmd(command)
    if code == 0:
        return True

def launch_expect():
    command = '/usr/bin/expect {}'.format(expect_script) #, expect_output)
    run_bg_cmd(command, expect_output, expect_output)
    print("Launched: {}".format(command))

def execute(fn):
    print(f'Executing {fn}') 
    if fn == 'kill':
        is_running = check_run()
        if is_running:
            print('Killing expect script')
        else:
            print('No expect script running...')


def get_log(logfile):
    with open(logfile) as FD:
        command_results = FD.read()
    return command_results.readlines()[-10:]
    
def check_log(logfile):
    print('Checking result from expect script....')
    last_part = get_log(logfile) # if 'OK' in last_part[-1]:
    actions=[{'filter':'invalid command name','function':'kill'}]
    for line in last_part:
        for action in actions:
            if action['filter'] in line:
                execute(action['function'])
        pass

#launch_expect()
while check_run():
    # waiting for expect to finish
    time.sleep(5)
    prit('=')
    if check_run_time():
        # install has exceeded timeout, check for errors
        break;
print()
check_log(expect_output)
print('expect has exited !')