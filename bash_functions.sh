# beware that zsh counts certain things from 1 instead of zero
source_path=
function install_me() {
    # copy over .zsh_functions to home of profile and source this file.
    # Skip "init_profile_setup" if the user has told us to stay quite
    [[ ! -e ~/.dont-install-functions ]] && init_profile_setup
}

function init_profile_setup (){
    [[ ! -e ~/.config/.profile_setup_done ]] && setup_profile
}

function setup_profile() {
    # The real work
    check_shell
    check_rc_file
    check_aliases_functions
    check_config_file
}
function check_add() {
    rc_addon_file=${1}
    prefix='~/.'"${shell_name}_${rc_addon_file}"
    present=$(grep -e "${prefix}" ${rc_file} ; echo $?)
    [[ ${present} -eq 0 ]] && addon ${prefix} || printf "Error %S ocurred" ${present}
}

function addon() {
    func=${1}
    line="[[ -e ${func} ]] && source ${func}"
    printf "%s\n" "${line}" >> ${rc_file}
}
function check_shell() {
    shell_name=$(basename ${SHELL})
    [[ -z ${HOME} ]] && HOME=~
    [[ ${shell_name} == zsh ]] && is_zsh=true
}
function check_rc_file (){
    # if SHELL is zsh set to zsh_rc
    [[ -n ${is_zsh} ]] && rc_file=${HOME}/.zshrc

    # if rc_file still undefined, set to bash
    [[ -z ${rc_file} ]] && rc_file=${HOME}/.bashrc

    # check if a file or a link exists
    [[ ! -e ${rc_file} ]] && touch ${rc_file}
    # check if bash_rc contains aliases and functions sourcings
    for type in aliases functions bindkeys
    do  
        check_add ${type}
    done
}