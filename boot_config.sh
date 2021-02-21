#!/bin/bash
# ---------------------------------------------------------------------------------------
# This script is to replace some variables in network and user configs file, Jinja
# templating is a better choice but just for the sake of practicing bash scripting I am
# doing this.
# ---------------------------------------------------------------------------------------
set -euo pipefail

# ---------------------------------------------------------------------------------------
# Vars
# ---------------------------------------------------------------------------------------
BOOT_LOADER_DIR=${BOOT_LOADER_DIR:-/tmp}

# ---------------------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------------------
edit_config () {
    if [ $# -eq 3 ]; then
        local PLACE_HOLDER="$1"
        local VALUE="$2"
        local FILE="$3"

        if [ $MACHINE == "Linux" ]; then
            sed -i "s/{{ $PLACE_HOLDER }}/$VALUE/g" "$FILE"
        elif [ $MACHINE == "Mac" ]; then
            sed -i '' "s/{{ $PLACE_HOLDER }}/$VALUE/g" "$FILE"
        fi
    else
        echo -e "Expected 3 arguments, got ${#}.\nProvice PLACE_HOLDER, VALUE and FILE"
    fi
}

# ---------------------------------------------------------------------------------------
# Script
# ---------------------------------------------------------------------------------------

scriptdir="$(dirname $0)"

cd ${scriptdir}


uname_out="$(uname -s)"

case "${uname_out}" in
    Linux*)
        MACHINE=Linux;;
    Darwin*)    
        MACHINE=Mac;;
    *)
        MACHINE="UNKNOWN:${uname_out}"
        exit 1
esac


configs=( "./boot/network-config" "./boot/user-data" )
# Hash maps are not supported in Bash 3
config_key=( "WIFI_ACCESS_POINT" "WIFI_ACCESS_POINT_PASS" "SSH_AUTHORISED_KEYS" )
config_value=( "${WIFI_ACCESS_POINT:=none}" "${WIFI_ACCESS_POINT_PASS:=nopass}" "${SSH_AUTHORISED_KEYS:=''}" )

for f in ${configs[@]}; do
    cp $f $BOOT_LOADER_DIR
    echo "${BOOT_LOADER_DIR}/${f##*/}"
    for i in "${!config_key[@]}"; do  
        edit_config ${config_key[i]} ${config_value[i]} ${BOOT_LOADER_DIR}/${f##*/}
    done
done