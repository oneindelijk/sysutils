#!/bin/bash






function update_source() {
    check_register
    check_size
    check_space
    perform_copy
    report
    clean_up
    register
}


function main() {
    action=$(check_new_isos)
    [[ -n ${action} ]] && update_source

}

main 