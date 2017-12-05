/*                                                                    *
 *                                                                    *
 *        Name: hello.c ("Hello, World!")                             *
 *        Date: 2007 and following                                    *
 *              This program is part of the CMS Make package.         *
 *              A simple C program for validation of 'make'.          *
 *                                                                    *
 *                                                                    */

#include <sys/utsname.h>
#include <stdio.h>

#include "cmsmake.h"

int main()
  {
    static  char  *_eye_catcher = "CMS Make - hello.c";
    int  rc;
    struct  utsname  hellouts;

    rc = uname(&hellouts);

    (void) printf("Hello, World!\n");

    (void) printf("CMS Make version %s\n",MAKE_VERSION);

/*
    rc = uname(&hellouts);
    if (rc != 0) { (void) perror("uname()"); (void) exit(rc); return rc; }
 */

    (void) printf("         sysname %s\n",hellouts.sysname);
    (void) printf("        nodename %s\n",hellouts.nodename);
    (void) printf("      OS release %s\n",hellouts.release);
    (void) printf("      OS version %s\n",hellouts.version);
    (void) printf("         machine %s\n",hellouts.machine);

    return 0;
  }


