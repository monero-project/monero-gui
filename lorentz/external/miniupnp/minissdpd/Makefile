# $Id: Makefile,v 1.30 2018/02/23 13:59:44 nanard Exp $
# MiniUPnP project
# author: Thomas Bernard
# website: http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
# for use with GNU Make (gmake)
# install with :
# $ PREFIX=/tmp/dummylocation make install
# or
# $ INSTALLPREFIX=/usr/local make install
# or
# make install (miniupnpd will be put in /usr/sbin)
#
# install target is made for linux... sorry BSD users...
#CFLAGS = -g -O0
CFLAGS ?= -Os
CFLAGS += -Wall
CFLAGS += -W -Wstrict-prototypes
CFLAGS += -fno-strict-aliasing -fno-common
CFLAGS += -D_GNU_SOURCE
#CFLAGS += -ansi
CC ?= gcc
RM = rm -f
INSTALL = install
OS = $(shell $(CC) -dumpmachine)

ifneq (, $(findstring linux, $(OS)))
	LDLIBS += -lnfnetlink
endif
ifeq ($(DEB_HOST_ARCH_OS), kfreebsd)
	LDLIBS += -lfreebsd-glue
else
ifneq (, $(findstring sun, $(OS)))
	CFLAGS += -D_XOPEN_SOURCE
	CFLAGS += -D_XOPEN_SOURCE_EXTENDED=1
	CFLAGS += -D__EXTENSIONS__
	LDFLAGS += -lsocket -lnsl -lresolv
endif
endif

#EXECUTABLES = minissdpd testminissdpd listifaces
EXECUTABLES = minissdpd testminissdpd testcodelength \
              showminissdpdnotif
MINISSDPDOBJS = minissdpd.o openssdpsocket.o daemonize.o upnputils.o \
                ifacewatch.o getroute.o getifaddr.o asyncsendto.o
TESTMINISSDPDOBJS = testminissdpd.o printresponse.o
SHOWMINISSDPDNOTIFOBJS = showminissdpdnotif.o printresponse.o

ALLOBJS = $(MINISSDPDOBJS) $(TESTMINISSDPDOBJS) \
          $(SHOWMINISSDPDNOTIFOBJS) \
          testcodelength.o

INSTALLPREFIX ?= $(PREFIX)/usr
SBININSTALLDIR = $(INSTALLPREFIX)/sbin
MANINSTALLDIR = $(INSTALLPREFIX)/share/man


.PHONY:	all clean install depend check test

all:	$(EXECUTABLES)

test:	check

clean:
	$(RM) $(ALLOBJS) $(EXECUTABLES)

install:	minissdpd
	$(INSTALL) -d $(SBININSTALLDIR)
	$(INSTALL) minissdpd $(SBININSTALLDIR)
	$(INSTALL) -d $(MANINSTALLDIR)/man1
	$(INSTALL) minissdpd.1 $(MANINSTALLDIR)/man1/minissdpd.1
ifeq (, $(findstring darwin, $(OS)))
	$(INSTALL) -d $(PREFIX)/etc/init.d
	$(INSTALL) minissdpd.init.d.script $(PREFIX)/etc/init.d/minissdpd
endif

check:	validateminissdpd validatecodelength

validateminissdpd:	testminissdpd minissdpd
	./testminissdpd.sh
	touch $@

validatecodelength:	testcodelength
	./testcodelength
	touch $@

minissdpd: $(MINISSDPDOBJS)

testminissdpd:	$(TESTMINISSDPDOBJS)

showminissdpdnotif:	$(SHOWMINISSDPDNOTIFOBJS)

testcodelength:	testcodelength.o

listifaces:	listifaces.o upnputils.o

config.h:	VERSION
	@tmp=`grep -n MINISSDPD_VERSION $@` ; \
	line=`echo $$tmp | cut -d: -f1` ; \
	old_version=`echo $$tmp | cut -d\\" -f2` ; \
	new_version=`cat VERSION` ; \
	if [ "$$new_version" != "$$old_version" ] ; then \
		echo "updating VERSION in $@ from $$old_version to $$new_version"; \
		sed "$${line}s/$${old_version}/$${new_version}/" $@ > $@.temp ; \
		mv $@.temp $@ ; \
	fi

depend:
	makedepend -f$(MAKEFILE_LIST) -Y \
	$(ALLOBJS:.o=.c) 2>/dev/null

# DO NOT DELETE

minissdpd.o: config.h getifaddr.h upnputils.h openssdpsocket.h
minissdpd.o: minissdpdtypes.h daemonize.h codelength.h ifacewatch.h
minissdpd.o: asyncsendto.h
openssdpsocket.o: config.h openssdpsocket.h minissdpdtypes.h upnputils.h
daemonize.o: daemonize.h config.h
upnputils.o: config.h upnputils.h getroute.h minissdpdtypes.h
ifacewatch.o: config.h openssdpsocket.h minissdpdtypes.h upnputils.h
getroute.o: getroute.h upnputils.h
getifaddr.o: config.h getifaddr.h
asyncsendto.o: asyncsendto.h upnputils.h
testminissdpd.o: codelength.h printresponse.h
printresponse.o: codelength.h
showminissdpdnotif.o: codelength.h printresponse.h
printresponse.o: codelength.h
testcodelength.o: codelength.h
