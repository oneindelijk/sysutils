#!/usr/bin/env python3
version = '0.0.1'
"""
  -- upgrade_companion --

  Path: ~/sysutils/upgrade_companion.py
  BY: Sam Van Kerckhoven <sam.vankerckhoven@cipalschaubroeck.be> 
  Created: Wed 09 Sep 2020

  Purpose: Check the output of the expect script and take corrective measurements

"""
import shutil
import time
import re
home = shutil.os.environ['HOME']
modpath = shutil.os.path.join(home, 'Python/mods')
shutil.sys.path.append(modpath)
from my_system import run_cmd, run_bg_cmd, prit

# variables

#expect_script2 = '/home/sam/systemen/systemen/intern/expect/pikaur_wrapper.expect'
expect_script = '/home/sam/sysutils/pikaur_wrapper.expect'
single_pkg_script = '/home/sam/sysutils/pikaur_wrapper_single_pkg.expect'
expect_output = '/home/sam/log/pikaur_wrapper-expect.log'
expect_output2 = '/home/sam/log/pikaur_wrapper-expect-single-pkg.log'
started = None
timeouts = 0
wait_time = 1  # minutes
def check_run_time():
    global started
    # set starting time when not set
    if started == None:
        started = time.time()
    if time.time() - started > wait_time * 60:
        timeouts =+ 1
        started = time.time()
        return True

def check_run():
    command = "ps ax | grep -v grep | grep -e 'expect '"
    result, error, code = run_cmd(command)
    if code == 0:
        return True

def launch_expect():
    global expect_output, expect_script
    if not check_run():
        command = '/usr/bin/expect {}'.format(expect_script) #, expect_output)
        run_bg_cmd(command, expect_output, expect_output)
        print("Launched: {}".format(command))
    else:
        print('Still a running process... Not launching a new one')

def execute(fn, payload = None):
    global single_pkg_script
    print(f'Executing {fn}') 
    if fn == 'kill':
        is_running = check_run()
        if is_running:
            print('Killing expect script')
            run_cmd('pkill expect')
        else:
            print('No expect script running...')
    elif fn == 'single pkg upgrade':
        pkg = package_from_payload(payload)
        if pkg:
            # make sure expect script is stopped
            time.sleep(2)
            execute('kill')
            time.sleep(2)
            print(f'Trying installing single package {pkg}')
            cmd = f'/usr/bin/expect {single_pkg_script} {pkg} &> {expect_output2}'
            logfile = '/home/sam/log/single_pkg_install.log'
            result, error, code = run_cmd(cmd)
            if code == 0:
                print('Installing f{pkg) seemed to have worked. Trying upgrade again')
                return True
            else:
                print(result, error)
                return False


def package_from_payload(data):
    if ' vervangen ' in data:
        R = re.compile('met\ [a-z]*/*([a-z-]+)\?') 
        S = R.search(data)
        if S:
            pkg = S.groups()[0]
            return pkg

def get_log(logfile):
    with open(logfile) as FD:
        command_results = FD.read()
    return command_results.splitlines()[-10:]
    
def check_log(logfile):
    print('Checking result from expect script....')
    last_part = get_log(logfile) # if 'OK' in last_part[-1]:
    actions=[
        {'filter':'invalid command name','function':'kill'},
        {'filter':' vervangen ','function':'single pkg upgrade'},
            ]
    for line in last_part:
        for action in actions:
            if action['filter'] in line:
                execute(action['function'], line)
        pass

launch_expect()
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