function load_vars(){
    pfile=.menu/${1}.prop
    [[ ! -f ${pfile} ]] && echo File not found ${pfile} || source ${pfile}

}

function change_var(){
    # define the name for the property file
    pfile=.menu/${1}.prop
    [[ ! -f ${pfile} ]] && echo File not found ${pfile}
    var=${2}
    value=${3}
    # construct the command for replacing the old value with the new value
    sedcmd="/^${var}=/ s:=.*:=${value}:"
    # check if the 'var' is present in the file
    grep ${var} ${pfile} > /dev/null
    # replace the line in the file if var was found
    [[ $? -eq 0 ]] && sed -i "${sedcmd}" ${pfile}

}

function random(){
    # fix alternative if no python3
    LOWER=${1}
    UPPER=${2}
    [[ -z ${LOWER} ]] && LOWER=0
    [[ -z ${UPPER} ]] && UPPER=100
    
    python -c "import random;print(random.randint(${LOWER},${UPPER}))"
}

function template(){
    property_name="${1}"
    template_name=${2}
    cp .menu/${template_name}.tmpl .menu/${property_name}.prop
}

function confirm(){
    printf "%s: (Y/N)" "${@}" >2
    read answ
    [[ ${answ} =~ [yY] ]] && echo 0 || echo 1
}

function new_property_file() {
    # creates a new file based on a template
    # if ${overwrite} is empty, confirmation will be asked, 
    #yY wil always overwrite, other chars will leave file alone
    property_name=${1}
    template_file="${2}"
    overwrite=${3}
    unset ok
    pfile=.menu/${property_name}.prop
    if [[ ! -f ${pfile} ]] ;then
       ok=yes
    else
        if [[ ${overwrite} =~ [yY] ]] ;then
            ok=yes
        fi
        if [[ -z ${overwrite} ]] ; then
            continue=$(confirm "Overwrite existing file ?")
            [[ ${continue} -eq 0 ]] && ok=yes
        fi
    fi
    [[ ! -z ${ok} ]] && template  ${property_name} ${template_file}
}
function add_to_list() {
    listname_name=${1}
    lfile=.menu/${listname_name}.ilist
    shift
    value="${@}"
    last=$(tail -n 1 ${lfile})
    last_id=${last/,*}
    index=$((last_id + 1))
    printf "%s,%s\n" "$((last_id + 1))" "${value}" >> ${lfile}
    echo ${index}
}
function return_index_value() {
    listname_name=${1}
    index="${2}"
    lfile=.menu/${listname_name}.ilist
    grep '^'"${index}"',' ${lfile}
}
function get_numbered_array() {
    declare -a tmp_array
    listname_name=${1}
    lfile=.menu/${listname_name}.ilist
    while read line; do
        COUNT=${COUNT+1}
        ID=${line/,*}
        ITEM="${line/*,}"
        tmp_array+=( "${ID}" "${ITEM}" )
    done < ${lfile}
    COUNT=$((ID+1))
    extra_name="Edit-Menu"
    tmp_array+=( "${COUNT}" "${extra_name}" )
    printf '%s' "${tmp_array[@]}"   
}