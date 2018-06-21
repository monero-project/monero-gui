#!/bin/bash


function get_platform {
    local platform="unknown"
    if [ "$(uname)" == "Darwin" ]; then
        platform="darwin"
    elif [ "$(uname)" == "FreeBSD" ]; then
        platform="freebsd"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if [ "$(expr substr $(uname -m) 1 6)" == "x86_64" ]; then
            platform="linux64"
        elif [ "$(expr substr $(uname -m) 1 4)" == "i686" ]; then
            platform="linux32"
        elif [ "$(expr substr $(uname -m) 1 6)" == "armv7l" ]; then
            platform="linuxarmv7"
	elif [ "$(expr substr $(uname -m) 1 7)" == "aarch64" ]; then
            platform="linuxarmv8"
	else
            platform="linux"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        platform="mingw64"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        platform="mingw32"
    fi
    echo "$platform"

}


function get_tag()
{
  COMMIT=$(git rev-parse --short HEAD | sed -e 's/[\t ]*//')
  if test $? -ne 0
  then
    echo "Cannot determine current commit. Make sure that you are building either from a Git working tree or from a source archive."
    VERSIONTAG="unknown"
  else
    echo "You are currently on commit ${COMMIT}"
    TAGGEDCOMMIT=$(git rev-list --tags --max-count=1 --abbrev-commit | sed -e 's/[\t ]*//')
    if test -z "$TAGGEDCOMMIT"
    then
      echo "Cannot determine most recent tag. Make sure that you are building either from a Git working tree or from a source archive."
      VERSIONTAG=$COMMIT
    else
      echo "The most recent tag was at ${TAGGEDCOMMIT}"
      if test "$TAGGEDCOMMIT" = "$COMMIT"
      then
        echo "You are building a tagged release"
        VERSIONTAG="release"
      else
        echo "You are ahead of or behind a tagged release"
        VERSIONTAG="$COMMIT"
      fi
      # save tag name + commit if availible
      TAGNAME=$(git describe --tags | sed -e 's/[\t ]*//')
      if test -z "$TAGNAME"
      then
        TAGNAME="$VERSIONTAG"
      fi
    fi
  fi
}










