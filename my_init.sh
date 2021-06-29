#!/bin/bash
version="0.0.1"
function header() {
	printf "%s\n" "New System Init"
}

function set_up_shell() {
	if [[ ! -e ~/.bash_aliases ]] && [[ ! -e ~/.zsh_aliases ]]
	then
		setup_aliases
	fi
}

function setup_aliases() {
	if [[ -z ${user_option_shell} ]]
	then
		pick_shell
	fi
	
}
function pick_shell() {
	shells='''
	bash
	csh
	dash
	fish
	tcsh
	zsh
	'''




}

function check_os() {
	id_line=$(uname -a)
	[[ ${id_line} =~ *raspberrypi* ]] && OS=raspberry
	[[ ${id_line} =~ *armv[0-9]* ]] && ARCH=arm

}

function checks() {
	check_os
	# check ssh key
	# check shell
	# check ipython
	# enable ansible
}

function main() {
	header
	checks
}

main
