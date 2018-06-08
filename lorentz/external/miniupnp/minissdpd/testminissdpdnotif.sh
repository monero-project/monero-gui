#!/bin/sh
# $Id: $
# (c) 2016 Thomas Bernard

OS=`uname -s`
IF=lo
if [ "$OS" = "Darwin" ] || [ "$OS" = "SunOS" ] ; then
	IF=lo0
fi
# if set, 1st argument is network interface
if [ -n "$1" ] ; then
	IF=$1
fi

# trap sigint in the script so CTRL-C interrupts the running program,
# not the script
trap 'echo SIGINT' INT

SOCKET=`mktemp -t minissdpdsocketXXXXXX`
PID="${SOCKET}.pid"
./minissdpd -s $SOCKET -p $PID -i $IF  || exit 1
sleep .5
echo "minissdpd process id `cat $PID`"
./showminissdpdnotif -s $SOCKET
echo "showminissdpdnotif returned $?"
kill `cat $PID`
