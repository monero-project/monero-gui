#!/bin/bash


function get_platform {
    local platform="unknown"
    if [ "$(uname)" == "Darwin" ]; then
        platform="darwin"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if [ "$(expr substr $(uname -m) 1 6)" == "x86_64" ]; then
            platform="linux64"
        else
            platform="linux32"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        platform="mingw64"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        platform="mingw32"
    fi
    echo "$platform"

}












