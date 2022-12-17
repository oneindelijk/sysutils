srcs=['Deloitte/git/dap-choria/modules/choriaplaybooks/plans/reset_gitlab_maintenance_tasks.pp',
'Deloitte/git/dap-choria/modules/utils/lib/puppet/functions/utils/get_gitlab_task_result.rb',
'Deloitte/git/dap-choria/modules/choriaplaybooks/plans/git_add_label_to_maintenance_task.pp',
'Deloitte/git/dap-choria/modules/utils/lib/puppet/functions/utils/get_gitlab_issue_value.rb',
'Deloitte/git/dap-choria/modules/utils/lib/python/functions/utils/get_gitlab_issues_servers.py',
'Deloitte/git/dap-choria/modules/choriaplaybooks/plans/reset_gitlab_server_issues.pp']
import shutil                                                                       
import functools
import time
import logging 
logging.basicConfig(level=logging.INFO)
def cache(func):
    @functools.wraps(func)
    def func_info(name, **kw):
        fname = name.replace('/','_')
        path = f'/tmp/{fname}.tstamp'
        logging.debug(path)
        if shutil.os.path.exists(path):
            saved_time = open(path,'r').read()
            logging.debug(f'Time read from cachefile: {saved_time}')
            output = func(name, saved_time=saved_time)
        else:
            output = func(name, **kw)
        if output.__class__ == str:
            logging.debug(f'Return from function: {output}')
            open(path,'w').write(output)

        return output
    
    return func_info    


def get_remote_stat_mtime(server, port, path):                                                                                                                                                                                                          
    sshcmd = f"ssh {server} -p {port} \"stat -c '%y' {path}\""  
    logging.debug(sshcmd)
    result = get_ipython().getoutput(sshcmd) 
    logging.debug(f'Time from file: {result}')                                                                                                                                                                                                    
    return result[0]                                                                                                                                                                                                                             
                                                                                                                                                                                                                                               
def get_local_stat_mtime(path):
    srcstat = get_ipython().getoutput(f"stat -c '%y' {path}")
    return srcstat[0]

@cache
def check_remote_stat_mtime(path, saved_time = None):
    ''' return True if no saved_time is stored or 
    if saved time is different from current '''
    last = get_remote_stat_mtime('sskul', 22, path)
    logging.debug(f'Last: {last} saved_time: {saved_time}')
    if last != saved_time:
        return last
    if saved_time == None:
        return True
    return False

def compare_mtime(path):
    if check_remote_stat_mtime(path):
        remote_copy(path)
        return True
    return False

def remote_copy(path):
    basename = shutil.os.path.basename(path)
    scpcmd = f'scp sskul:{path} dapchoriaprd01:plans'
    logging.info(f'Copy command: {scpcmd}')
    get_ipython().system(scpcmd)

def check_files(files):
    changed = False
    for path in files:
        if compare_mtime(path):
            changed = True
            open('/tmp/changed.marker','w').write(str(time.time()))

while True:
    try:
        check_files(srcs)
        # print('Interrupt now')
        time.sleep(3)                                                                                                                                                                        
    except KeyboardInterrupt:                                                                                                                                                                                                                    
        logging.info('CTRL-C pressed. Exiting...')                                                                                                                                                                                                        
        break         





#   try:                                                                                                                                                                                                                                         
#     for i, src in enumerate(srcs):                                                                                                                                                                                                             
#       sfile = f'srcstat{i}.t'                                                                                                                                                                                                                  
#       if shutil.os.path.exists(sfile):                                                                                                                                                                                                         
#         laststat = open(sfile).read().strip()                                                                                                                                                                                                  
#         srcstat = get_ipython().getoutput(f"stat -c '%y' {src}")                                                                                                                                                                               
#       else:                                                                                                                                                                                                                                    
#         laststat = 0                                                                                                                                                                                                                           
#         srcstat = get_ipython().getoutput(f"stat -c '%y' {src}")                                                                                                                                                                               
                                                                                                                                                                                                                                               
#       if laststat != srcstat[0]:                                                                                                                                                                                                               
#         now = time.ctime()                                                                                                                                                                                                                     
#         get_ipython().system(f"stat -c '%y' {src} > {sfile}")                                                                                                                                                                                  
#         logging.info(f'Updating {src}', now)                                                                                                                                                                                                          
#         get_ipython().system('scp {src} dapchoriaprd01:plans')            