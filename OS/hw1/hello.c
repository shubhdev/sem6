#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
void main(){
	// char * const argv[] = {"/usr/bin/env","ls",0};
	// int ret = execv(argv[0],argv);
	
	// printf("%s\n",strerror(errno));
	int x;
	scanf("%d",&x);
	printf("%d",x);
}