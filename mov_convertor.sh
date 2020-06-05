version='0.9'
### FUNCTIONS
tmp_dir=~/tmp
config=~/.config/mov_convertor.cfg
source ${config}
latestbase=${tmp_dir}/latest
runfile=~/.movcrt.run

function log() {
    msg=${@}
    timestamp=$(date '+%F %T')
    if [[ -n ${debug} ]]
    then
        printf "%18s |%s| %s\n" "${timestamp}" "${version}" "${msg}" | tee -a log/mov_convertor.log
    else
        printf "%18s |%s| %s\n" "${timestamp}" "${version}" "${msg}" >> log/mov_convertor.log
    fi
}


function init_script() {
    [[ ! -d ${tmp_dir} ]] && mkdir ${tmp_dir} &&  chown -vR ${makefromUser}: ${tmp_dir} && log created ${tmp_dir}
    [[ -n ${debug} ]] && log Script ${version} using config ${cfg_version}
    [[ -e ${runfile} ]] && log Already a running instance && exit 1 
    [[ ! -d ${workingdir} ]] && log no working dir exists ${workingdir} && exit 1
    for check_var in destinationfolder backupfolder makefromUser
    do
        [[ -z ${!check_var} ]] && log ${check_var} is not defined && exit 1
    done
    for check_fold in ${destinationfolder} ${backupfolder} ${watchfolders[@]} 
    do        
        check_folder=${workingdir}${check_fold}
        if [[ ! -d ${check_folder} ]]   
        then
            log Creating ${check_folder}
            mkdir ${check_folder}
            chown -vR ${makefromUser}: ${check_folder}
        fi
    done
}
function extract_formats (){
    source_folder=${1}
    dst_tussen=${source_folder/-van-*}
    destination_format=${dst_tussen/*-}
    source_format=${source_folder/*-van-}
    log Converting from ${source_format} to ${destination_format}
}
function execute_conversion() {
    src="${1}"
    dst="${2}"
    log "Doing Conversion for ${src} ${dst}" 
    log setting runfile
    touch ${runfile}
    # conversion
    cmd="ffmpeg -i ${src} ${dst}"
    log Running ${cmd}
    ${cmd} &> ${tmp_dir}/ffmpeg_result 
    if [[ $? -ne 0 ]] 
    then 
      mv ${tmp_dir}/ffmpeg_result "${err_file}" 
      log Error in file "${err_file}" 
    else
      Conversion of ${src} succesful
      mv "${src}" ${workingdir}${backupfolder}
    fi
    log remove runfile
    rm ${runfile}
}
function prepare_file_for_conversion() {
    mov_file="${1}"
    #set -x
    sourcefile="${watch_folder}/${mov_file}"
    filebase="${mov_file/\.*}"
    target="${workingdir}${destinationfolder}/${filebase}.${destination_format}"
    #set +x 
    log Preparing ${sourcefile} for conversion
    log Creating ${target} from conversion
    set -x
    extension="${sourcefile/*\.}"
    if [[ "${extension,,}" = ${source_format} ]] 
    then
        execute_conversion "${sourcefile}" "${target}"
    else
        log ERROR not a mov file ${mov_file,,}
        echo ERROR not a mov file ${mov_file,,} > "${err_file}"
    fi
    set +x
}
function check_drop_dir () {
    drop_dir="${@}"
    watch_folder="${workingdir}${drop_dir}"
    latest=${latestbase}-${drop_dir}
    latest_bu=${latest}-$(date '+%F-%H_%M')
    [[ -z ${drop_dir} ]] && log no drop_dir given && return 1
    [[ -f ${latest} ]] && mv ${latest} ${latest_bu}
    log storing contents ${watch_folder} #to ${latest}
    ls -1 ${watch_folder} > ${latest}
    while read mov_file  
    do
        err_file="${source_folder}/${mov_file/\.*}.ERROR"
        extension="${mov_file/*\.}"
        if [[ ${extension} = ERROR ]]
        then
           ok=ok
        else
        if [[ ! -e "${err_file}" ]]
        then
            prepare_file_for_conversion "${mov_file}"
        else
            log Skipping "${mov_file}" in Error
        fi
        fi
    done < ${latest}

    return 0
}
function check_allwatchfolders( ){
    for wfolder in ${watchfolders[@]} 
    do
        log Checking ${wfolder} for new files
        extract_formats ${wfolder}
        check_drop_dir ${wfolder}
        # result=$(check_drop_dir ${wfolder})
        # log The folder returns ${result}
    done
}

function get_dir_hist() {
    echo dd
}
# check if there is a new file
    # convert it
    # move it to backup
    # make logfile
    # clean up old logfile

init_script
check_allwatchfolders