#!/bin/bash

gitlabfile=wget-list.txt

[[ ! -e ${gitlabfile} ]] && printf "File %s not found\n" "${gitlabfile}" !! && exit 1

# ensure line endings are unix style
dos2unix ${gitlabfile} 
while read url
do
    if [[ ${url: :1} = "h" ]]
    then
        # remove git extension
        if [[ ${url##*.} = git ]]
        then
            url=${url%.git}
        fi    
        # format git name
        repo_url=${url}.git
        # get folder name
        folder=${url##*/}
        # clone git if folder doesn't exists yet
        if [[ ! -d ${folder} ]]
        then    
            git clone ${url}
        else
            printf "Skipping %s. (Directory %s exists)\n" "${url}" "${folder}"
        fi
    fi
done < ${gitlabfile}