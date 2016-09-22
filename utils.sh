#!/bin/bash


function get_platform {
    local platform="unknown"
    if [ "$(uname)" == "Darwin" ]; then
        platform="darwin"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        platform="linux"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        platform="mingw64"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        platform="mingw32"
    fi
    echo "$platform"

}












