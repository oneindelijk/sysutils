#!/usr/bin/env python3



# new version in /home/sam/Python/auto_scp/auto_copy.py





print('new version in /home/sam/Python/auto_scp/auto_copy.py')

import shutil 
shutil.sys.exit()
home='/home/sam'
shutil.sys.path.append(shutil.os.path.join(home,'Python/mods'))
import time
#import my_system
from my_system import run_cmd, wiz_select_nb
from db_class import Info
from my_logs import log, log_init
autocopy_info = shutil.os.path.join(home,'.config/autocopy-script.json')
logdir = shutil.os.path.join(home,'log')
logfile = 'auto_scp_manage.log'
loglevel='info'

q_newpath='Enter new path for the presetfiles :'
q_create_dir='Create folder {} (Y/N) ? '
q_default_set='Set val {} :'
t_default_title='Change or remove {} (Y/N)'

def check_age(sourcefile ):
    age = shutil.os.stat(sourcefile).st_mtime
    return age

def manage_defaults(variable):
    if not 'defaults' in Config.data:
        Config.data['defaults'] = {}
    if variable=='*':
       preset = wiz_select_nb(Config.data['presetlist'], force_Horizontal=False) 
       load_preset(preset, Config.data).re_init()
    if variable in Config.data['defaults']:
        defaults = Config.data['defaults'][variable]
        if len(defaults) > 0:
           choice = wiz_select_nb(defaults)
           if choice == '*':
               # remove a value, choose default or preset
                print (t_default_title.format(var=variable))
                pass
           if choice == None:
               # offer chance to enter more defaults
               newval = input(q_default_set.format(variable))
               if newval != '':
                  Config.data['defaults'][variable].append(newval) 
               return newval
           else:
               return choice 
               
    else:
        newval = input(q_default_set.format(variable))
        Config.data['defaults'][variable] = [newval]
        return newval
        

def fill_data(pres_data):
    def get_var():
        newval = input(q)
        if newval == '*':
            newval = manage_defaults(var)
        return newval

    print ('Enter new values: {} lets you pick or enter defaults'.format("'*'"))
    new_data = [['source_file','Enter path of sourcefile','string'],
                ['destination_dir','Enter destination directory','string'],
                ['server','Enter destination server','string'],
                ['username','Enter username','string'],
                ['rename_to','Rename to extension. Leave empty to use original','string'],
                ['idfile','ssh_id_file','string'],
                ['port','The port to connect on','string'],
                ['option','The options','list'],
                ['init','Change this file next time. Type "y" if Finished','boolean']
    ]   
    for var, question, d_type in new_data:
        if var in pres_data:
            if pres_data[var].__class__ == list:
                varval = ', '.join(pres_data[var])
            else:
                varval = pres_data[var]
            q = ' :: {varname:20} :: {var:50}  ::\n{q}:'.format(q=question,var=varval,varname=var)
        else:
            q = question + ': '
        newval = get_var()
        if d_type == 'string':
            if newval != '':
                pres_data[var] = newval
                print ('Using: {}'.format(newval)) 
        elif d_type == 'list':
            if not var in pres_data:
                pres_data[var] = [newval]
            while newval != '': 
                if not newval in pres_data[var]:
                    pres_data[var].append(newval)
                newval = get_var()
        elif d_type == 'boolean':
            if newval in 'yesYESjaoui1':
               pres_data[var] = True
            elif newval in 'Nn0':
               pres_data[var] = False 
        else:
            log('Not implemented (or typo): {}'.format(d_type))

    #pres_data['init'] = 'done'
    return pres_data

def load_preset(presetName, data):
    filename = shutil.os.path.join(data['presetpath'],presetName + '.json')
    preset = Info(filename)
    if not shutil.os.path.isfile(filename):
        preset.name = presetName
    preset.load(create=True)
    if not 'init' in preset.data:
        preset.data = fill_data(preset.data)
    log('Loaded preset: {}'.format(presetName),10)
    return preset

def get_preset(Config):
    print('Enter preset:')
    choice = input(':')
    if choice != '':
        if 'presetlist' in Config.data: 
            Config.data['presetlist'].append(choice)
        else:
            Config.data['presetlist']=[choice]

def get_var_value(sstring):
    fmt='{}:\n'
    print (fmt.format(sstring))
    return input()

def init_config(config_data):
    if 'init' in config_data:
        if config_data['init'] == 'done':
            return config_data
    config_data['init'] = 'setup'
    if config_data['init'] == 'default':
        config_data['presetlist'] = []
        config_data['presetpath'] = shutil.os.path.join(home,'.presets/')
    if not 'presetlist' in config_data:
        config_data['presetlist'] = []
    if not 'presetpath' in config_data:
        newval = input(q_newpath)
        if newval != '':
           config_data['presetpath'] = newval 
    if 'presetpath' in config_data:
        if not shutil.os.path.isdir(config_data['presetpath']):
            if input(q_create_dir.format(config_data['presetpath'])) in 'yYjJ':
                shutil.os.makedirs(config_data['presetpath'])


    return config_data

def check_sync(presetdata):
    ''' checks if the mtime of the file is different than recorded
        Returns True if file is in sync, 
        false if newer or there are no records yet'''

    current_mtime = check_age(presetdata['source_file'])
    log("The age of the file is {}".format(current_mtime), 10)
    if not 'last_mtime' in presetdata:
       presetdata['last_mtime'] = current_mtime
       return False
    if presetdata['last_mtime'] != current_mtime:
        if not 'sync_history' in presetdata:
           presetdata['sync_history'] = []
        presetdata['sync_history'].append(presetdata['last_mtime'])
        presetdata['last_mtime'] = current_mtime
        return False
    
    return True

def secure_copy(presetdata):
    ''' Uses the presetdata to copy the file to the remote destination
        -v -P4900 -o StrictHostKeyChecking=no -o BatchMode=yes'''
    source_file = presetdata['source_file']
    basename = shutil.os.path.split(source_file)[1]
    if 'rename_to' in presetdata:
        rename_to = presetdata['rename_to']
        if rename_to != '':
            basename = shutil.os.path.split_ext(basename) + rename_to
    dest_file = shutil.os.path.join(presetdata['destination_dir'],basename)   
    options = ''
    for opt in presetdata['option']:
        options = '{} -o "{}"'.format(options,opt) 

    command = 'scp -v -i {idfile} -P {port} {options} {localfile} {user}@{server}:{destination}'.format(
            idfile = presetdata['idfile'],
            user = presetdata['username'],
            server = presetdata['server'],
            localfile = presetdata['source_file'],
            destination = presetdata['destination_dir'],
            port = presetdata['port'],
            options = '' #options
    )
    log (command, 8)
    result, error, code = run_cmd(command)
    log('Command ended with success {}'.format('-'), 10)
    if code != 0:
        log('Command ended with error {} {}'.format(result, error), 6)

log_init(loglevel, logdir, logfile)
log('Starting autoscp script. Logging set to {}'.format(loglevel),8)
Config=Info(autocopy_info)
Config.load(create=True)
Config.data = init_config(Config.data)
presetlist = Config.data['presetlist']
if len(shutil.sys.argv) > 1:
    for arg in shutil.sys.argv[1:]:
        try:
            choice = presetlist[int(arg) -1]
        except ValueError:
            print('error')
        except IndexError:
            print ('No such preset')
        else:
            log('Running {}'.format(choice), 10)
else:
    if len(presetlist) > 0:
        choice = wiz_select_nb(presetlist, force_Horizontal=False, return_mismatched=True)
        if choice=='*':
           manage_defaults(choice) 
# try:
#     print(choice)
# except NameError:
#     print('Choice not define: Enter preset:')
#     get_preset(Config)
if choice == None:
    get_preset(Config)
else:
    Preset = load_preset(choice, Config.data)
    Preset.save()
# enable this after debugging    
if not check_sync(Preset.data):
    secure_copy(Preset.data)
    #Preset.show()
    Preset.save()
else:
    log('No changes in {}'.format(Preset.path),10)

Config.save()