#!/bin/bash

f_add="addChecksum.py"
f_validate="validateChecksum.py"
files=("${f_add}" "${f_validate}")

date_short=$(date +'%Y%m%d')
date_long=$(date +'%B %d %Y')

function _download {
    wget "https://hg.adblockplus.org/adblockplus/raw-file/tip/${1}"
    chmod 0777 "${1}"
}

function _version {
    cmd_sed=(sed -i -r)
    if [ $(uname) == "Darwin" ] ; then
        cmd_sed=(sed -i '' -E)
    fi
    "${cmd_sed[@]}" "s/(! [Vv]ersion:)([[:print:]]+)?/\1 ${date_short}/g" "${1}"
    "${cmd_sed[@]}" "s/(! [Ll]ast [Mm]odified:)([[:print:]]+)?/\1 ${date_long}/g" "${1}"
}

function _checksum {
    python "${f_add}" < "${1}" > "_${1}"
    python "${f_validate}" < "_${1}"
    mv "_${1}" "${1}"
}

function _process {
    for file in *.txt ; do
        _version "${file}"
        _checksum "${file}"
    done
}

function _initialize {
    for file in "${files[@]}" ; do
        _download "${file}"
    done
}

function _terminate {
    rm -f *.py
}

function _main {
    _initialize
    _process
    _terminate
}

_main "$@"
