#!/usr/bin/env python3
version='0.0.1'
"""
  -- byobu_start --   Created: Fri 11 Dec 2020 

  Path: ~/sysutils/byobu_start.py
  Original in 	github.com/oneindelijk/Python-home.git
  BY: Sam Van Kerckhoven <oneindelijk@gmail.be> 

  Purpose: Create a predefined set of session, windows and panes in byobu from a configfile
  Config format:
    [session]
    window-name
    window-name | pane-name #horizontal split
    window-name : pane-name # vertical split 
  always follow a window-name or pane-name by a space
  after the space:
  - pipe symbol indicates a horizontal split
  - colon indicates a vertical split
  everything else indicates a command (until the next colon, pipe or end)

  commands are limited to contain alphanumeric and these extra characters ~/.-
  consider using aliases or more complex commands

"""
import shutil
import appdirs
from time import strftime
import re
mod_dir = '/home/sam/Python/mods'
shutil.sys.path.append(mod_dir)
from my_system import run_cmd
debuglevel = 10
configfile='byobu_windows.cfg'
logfile = None
def log(msg, severity = 4, cat = 'default'):
    if severity <= debuglevel:
        if logfile == None:
            print (msg)
        else:
            with open(logfile, 'a') as FD:
                FD.write('{:20}{}'.format(strftime('%Y-%m-%d %T'),msg))    
        
def read_config(cfgfile):
    path = shutil.os.path.join(appdirs.user_config_dir(),cfgfile)
    if not shutil.os.path.isfile(path):
        raise FileNotFoundError(f'{path} does not exist !')
    with open(path) as FD:
        cts = FD.read()
    return cts.splitlines()

def parse_config(configlines):

    def get_command(pane_line):
        pane_line = pane_line.strip(' ')
        if ' ' in pane_line:
            _ = pane_line.split(' ')
            windowname = _[0]
            command = ' '.join(_[1:])
            log (f'> command: `{command}`', 10)
            return {'name': windowname, 'command': command.strip(' ')}
        else:
            windowname = pane_line
            return {'name' :windowname}

    cfg = {}
    sessionRE = re.compile(r'^\[(\w+)\]')
    windowRE = re.compile(r'^([\w\s~/.-]+)')
    panesRE = re.compile(r'([:|][\w\s~/.-]+)')
    for lineno, line in enumerate(configlines):
        R = sessionRE.match(line)
        if R:
            session = R.groups()[0]
            cfg[session] = []
            log(f'Found SESSION {session}',10)
        else:
            Rw = windowRE.search(line)
            if Rw:
                window = Rw.groups()[0]
                log (f'windows: {Rw.groups()}', 10)
                win = get_command(window)
                Rp = panesRE.findall(line)
                if len (Rp) != 0:
                    win.update({'panes':[]})
                    for paneline in Rp:
                        log (f' || PANE {paneline}', 10)
                        ptype = 'hpane' if paneline[0] == ':' else 'vpane'
                        pane = get_command(paneline[1:])
                        pane.update({'panetype': ptype})
                        log (f'  || DICT {pane}', 10)
                        win['panes'].append(pane)

                cfg[session].append(win)        

            else:
                print ('The configfile contains an error on line {}: `{}`'.format(lineno + 1, line))
           
    return cfg
            
def create_session(sessionname):
    ''' create byobu session if it doesn't exists already '''
    command = 'byobu has-session -t {}'.format(sessionname)
    r, e, c = run_cmd(command)
    if c != 0:
        new_session = 'byobu new-session -d -s {}'.format(sessionname)
        run_cmd(new_session)
    else:
        log(f'Session {sessionname} already exists', 6)
        print (r,e,c)

def list_windows(sess):
    WINDOWS = []
    r, e, c = run_cmd('byobu list-windows -t {} -F "#I;#W"'.format(sess))
    if c == 0:
        for win in r.splitlines():
            window = win.split(';')
            WINDOWS.append({'name': window[1], 'index': window[0]})
    return WINDOWS

def create_window(sessionname, windowname):
    ''' create new window or rename if it is the first one '''
    wins = list_windows(sessionname)
    if len(wins) == 1 and wins[0]['name'] == 'zsh':
        command = 'byobu rename-window -t {}:0 {}'.format(sessionname, windowname) 
        log ('Renaming window {}:O to {}'.format(sessionname, windowname),8)
    else:
        if windowname in [n['name'] for n in wins]:
            log('Already a window with name {} in {}'.format(windowname, sessionname),6)
            return False
        else:
            command = 'byobu new-window -t {} -n {}'.format(sessionname, windowname)  
            log ('Creating new window {} in session {}'.format(windowname, sessionname),8)
    run_cmd(command)
    return True

def byobu_windows(cfg_dict):
    for session in cfg_dict:
        create_session(session)
        print (f' - {session} -')
        for WIN in CFG[session]:
            win = WIN['name']
            # cmd = "" if not "command" in WIN else WIN["command"]
            # print(f'    {win:6} : {cmd:18}', end = '')
            create_window(session, win)
            if "command" in WIN:
                cmd = WIN["command"]
                byobu_command(session, win, cmd)
            if 'panes' in WIN:
                for PANE in WIN['panes']:
                    pane = PANE['name']
                    cmd = "" if not "command" in PANE else PANE["command"]
                    print(f'{pane:6} : {cmd}', end = '')
                print()
            else:
                print('')

def byobu_command(sessionname, windowname, command):
    log ('Executing command in {}:{} `{}`'.format(sessionname, windowname, command))

if 'BYOBU_WINDOW_NAME' in shutil.os.environ:
    log("Script won't be executed in a byobu session !!",6)
else:

    cfg = read_config(configfile)
    CFG = parse_config(cfg)
    byobu_windows(CFG)


# attach-session
# list-panes -t win
# list-windows -t session -F '#I;#W'
# new-window -n name -t targetwin cmd
# tmux set-option remain-on-exit on
# tmux split-window 'ping -c 3 127.0.0.1'