#!/usr/bin/env python3
import shutil
home='/home/sam'
shutil.sys.path.append(shutil.os.path.join(home,'Python/mods'))
import time
from my_system import run_cmd
from db_class import Info

def update_state(VMS_DICT, id, state, value):
    VMS_DICT[id].update({state:value})
    return VMS_DICT
    
      
def toggle_vm(VMS_DICT,name):
    now = time.strftime('%a %d %H:%M')
    uid = VMS_DICT[name]['uid']
    options=''
    if 'headless' in VMS_DICT[name]:
        if VMS_DICT[name]['headless']:
            options = '--type headless '
    force=False
    if 'force' in VMS_DICT[name]:
        force = VMS_DICT[name]['force']
            
    if VMS_DICT[name]['state'] == 'ON':
        if 'Stopped_ts'in VMS_DICT[name]:
            if 'Started_ts' in VMS_DICT[name]:
                if VMS_DICT[name]['Started_ts'] > VMS_DICT[name]['Stopped_ts']:
                    force = True
            else:
                force = True
        VMS_DICT = update_state(VMS_DICT,name, 'Stopped', now)
        VMS_DICT = update_state(VMS_DICT,name, 'Stopped_ts', time.time())
        powercmd='VBoxManage controlvm {} acpipowerbutton'.format(uid)
        r, e, c = run_cmd(powercmd)
        if c==0:
            force=True
        if force:
            print('ACPI Poweroff failed. Doing hard shutdown\n{}'.format(e))
            powercmd = 'VBoxManage controlvm {} poweroff\n'.format(uid,r)
            run_cmd(powercmd)
        
        print ('{} has Shut Down (UUID: {}\n{})'.format(name, VMS_DICT[name]['uid'],powercmd))
    else:
        VMS_DICT = update_state(VMS_DICT,name, 'Started', now)
        VMS_DICT = update_state(VMS_DICT,name, 'Started_ts', time.time())
        powercmd='VBoxManage startvm {}{}'.format(options,uid)
        r, e, c  = run_cmd(powercmd)
        print ('{} has Started (UUID: {},\n{})'.format(name, VMS_DICT[name]['uid'],powercmd))
    return VMS_DICT
    
def get_all_vms():
    VMS={}
    all_vms=get_vms('vms')
    running=[flat[0] for flat in get_vms('runningvms')]

    for a_vm in all_vms:
        if a_vm[0] in running: 
            state = 'ON'
        else:
            state = 'OFF' 
        VMS[a_vm[0]] = {'name':a_vm[0], 'uid':a_vm[1], 'state':state}
    return VMS

def get_vms(v_cmd):
    cmd='VBoxManage list {}'.format(v_cmd)
    r, e, c = run_cmd(cmd)
    vmlist = r.splitlines()
    return [[vn[0].strip(' ').strip('"'),vn[1].strip('}')] for vn in [v.split('{') for v in vmlist]]

def validate_convert(val, vtype):
    if vtype=='bool':
        if val in 'Yy1':
            return True
        elif val in 'Nn0':
            return False
        else:
            return None
def set_options(SELECTIONS):
    global VMS
    data = VMS.data
    optionlist={1:{'option':'force','value': None,'type':'bool','text':'Y/N' },
                2:{'option':'headless','value': None,'type':'bool','text':'Y/N' },
                }
    fmt=' [{:2}] {:20}{}'
    selnaam = input('Select Virtual Machine to show options: ')
    naam=select(SELECTIONS, selnaam)
    print ('Changin options for {}'.format(naam))
    for id in optionlist:
        opt = optionlist[id]['option'] 
        if opt in data[naam]:
            option_value = data[naam][opt]
        else:
            option_value = 'n/a'
        print(fmt.format(id,opt,option_value))
    choice = input('Pick the option you want to change/add: ')
    OPTION = select(optionlist, choice) 
    if OPTION:
        new_value = input('[{}] {} ?: '.format(OPTION['text'],OPTION['option']))
        converted_value = validate_convert(new_value,OPTION['type'])
        if converted_value != None:


            print('update {} {} {}'.format(naam,OPTION['option'], converted_value)) 
            update_state(VMS.data, naam, OPTION['option'], converted_value)
        #print('update {} {} {}'.format(VMS.data,choice, new_value))
        VMS.save()   

    

def pick_vm(VMS_DICT, interactive, arg):
    SELECTION=[]
    formt = ' {:<3}{:24}{:6}{:40}{:18}{:18}'
    print(formt.format('','Name','State','uid','Started','Stopped'))
    for i, naam in enumerate(VMS_DICT.keys()):
        SELECTION.append(naam)
        j = VMS_DICT[naam]
        started = ''
        if 'Started' in j:
            started = j['Started']
        stopped = ''
        if 'Stopped' in j:
            stopped = j['Stopped']
        
        print (formt.format(i,naam, j['state'], j['uid'], started, stopped))
    if interactive:
        choice = input('Pick Virtual Machine (x for options): ')
    else:
        choice = arg

    
    SEL = select(SELECTION, choice)
    if SEL:
        return SEL
def select(SELECTION, choice):
    if choice == '':
        return
    try:
        selected = SELECTION[int(choice)]
    except:
        if choice == 'x':
            set_options(SELECTION)
            action=1
            return 1 # repeat
        print('Nothing selected.')
    else:
        return selected
VMS = Info(shutil.os.path.join(home,'.config/vms.json'))
VMS.load()
data = VMS.data
newdata = get_all_vms()
for vm in newdata:
    if vm in data:
        data[vm].update(newdata[vm])
    else:
        data[vm]=newdata[vm]
  

if shutil.sys.argv[1]!='':
    choice=pick_vm(data,False ,shutil.sys.argv[1] )
else:
    choice=pick_vm(data,True)
while choice==1:
    choice=pick_vm(data, True)
if choice:    
    data = toggle_vm(data, choice)
VMS.save()