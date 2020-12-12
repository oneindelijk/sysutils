#!/bin/bash
version="0.0.2"
(
cd ~/ansible
echo VERSION: ${version}
date
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
) >> ~/logs/git_pull.log 2>&1