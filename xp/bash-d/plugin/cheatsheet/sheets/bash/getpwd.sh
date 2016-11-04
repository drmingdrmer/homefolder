#!/bin/bash


# DIR="$( cd -P "$( dirname "$0" )" && pwd )"
# echo $DIR


# SCRIPT_PATH="${BASH_SOURCE[0]}";
# if ([ -h "${SCRIPT_PATH}" ]) then
#   while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
# fi
# pushd . > /dev/null
# cd `dirname ${SCRIPT_PATH}` > /dev/null
# SCRIPT_PATH=`pwd`;
# popd  > /dev/null


DIR="${BASH_SOURCE[0]}";
while [ -h "$DIR" ]; do DIR=`readlink "${DIR}"`; done
DIR="$( cd -P "$( dirname "$DIR" )" && pwd )"
