#!/bin/sh
# $Id: testminissdpd.sh,v 1.8 2017/04/21 11:57:59 nanard Exp $
# (c) 2017 Thomas Bernard

OS=`uname -s`
IF=lo
if [ "$OS" = "Darwin" ] || [ "$OS" = "OpenBSD" ] || [ "$OS" = "SunOS" ] || [ "$OS" = "FreeBSD" ] ; then
	IF=lo0
fi
# if set, 1st argument is network interface
if [ -n "$1" ] ; then
	IF=$1
fi
SOCKET=`mktemp -t minissdpdsocketXXXXXX`
PID="${SOCKET}.pid"
./minissdpd -s $SOCKET -p $PID -i $IF  || exit 1
./testminissdpd -s $SOCKET || exit 2
kill `cat $PID`
