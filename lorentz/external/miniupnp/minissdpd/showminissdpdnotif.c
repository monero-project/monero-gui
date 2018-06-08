/* $Id: $ */
/* vim: shiftwidth=4 tabstop=4 noexpandtab
 * MiniUPnP project
 * (c) 2016 Thomas Bernard
 * website : http://miniupnp.free.fr/ or http://miniupnp.tuxfamily.org/
 * This software is subject to the conditions detailed
 * in the LICENCE file provided within the distribution */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

#include "codelength.h"
#include "printresponse.h"

static volatile sig_atomic_t quitting = 0;

static void sighandler(int sig)
{
	(void)sig;
	quitting = 1;
}

int main(int argc, char * * argv)
{
	int i;
	int s;
	struct sockaddr_un addr;
	const char * sockpath = "/var/run/minissdpd.sock";
	unsigned char buffer[4096];
	ssize_t n;
	const char command5[] = { 0x05, 0x00 };
	struct sigaction sa;

	for(i=0; i<argc-1; i++) {
		if(0==strcmp(argv[i], "-s"))
			sockpath = argv[++i];
	}

	/* set signal handlers */
	memset(&sa, 0, sizeof(struct sigaction));
	sa.sa_handler = sighandler;
	if(sigaction(SIGINT, &sa, NULL)) {
		fprintf(stderr, "Failed to set SIGINT handler.\n");
	}
	sa.sa_handler = sighandler;
	if(sigaction(SIGTERM, &sa, NULL)) {
		fprintf(stderr, "Failed to set SIGTERM handler.\n");
	}

	s = socket(AF_UNIX, SOCK_STREAM, 0);
	addr.sun_family = AF_UNIX;
	strncpy(addr.sun_path, sockpath, sizeof(addr.sun_path));
	if(connect(s, (struct sockaddr *)&addr, sizeof(struct sockaddr_un)) < 0) {
		fprintf(stderr, "connecting to %s : ", addr.sun_path);
		perror("connect");
		return 1;
	}
	printf("connected to %s\n", addr.sun_path);
	n = write(s, command5, sizeof(command5));	/* NOTIF command */
	printf("%d bytes written\n", (int)n);

	while(!quitting) {
		n = read(s, buffer, sizeof(buffer));
		if(n < 0) {
			if(errno == EINTR) continue;
			perror("read");
			break;
		} else if(n == 0) {
			printf("Socket closed\n");
			break;
		}
		printf("%d bytes read\n", (int)n);
		printresponse(buffer, (int)n);
	}
	printf("Quit...\n");
	close(s);
	return 0;
}

