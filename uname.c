/*                                                                    *
 *                                                                    *
 *        Name: uname.c                                               *
 *        Date: 2010-May-13 (Thursday, last T320 meeting for JMT)     *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *                                                                    *
 *                                                                    */

#include <sys/utsname.h>
#include <unistd.h>
#include <stdio.h>

#include "cmsmake.h"

/*
#define  do_sysname  0x0001
#define  do_nodename  0x0002
#define  do_release  0x0004
#define  do_version  0x0008
#define  do_machine  0x0010
#define  do_domain   0x0020
       -s, --kernel-name        == sysname
       -n, --nodename           == nodename
       -r, --kernel-release     == release
       -v, --kernel-version     == version
       -m, --machine            == machine
           --domainname (maybe)
       --version                == CMS Make version
 */

int main()
  {
    static  char  *_eye_catcher = "CMS Make - uname.c";
    int  rc;
    struct  utsname  unameuts;

    (void) printf("CMS Make version %s\n",MAKE_VERSION);

    rc = uname(&unameuts);
    if (rc != 0) { (void) perror("uname()"); return rc; }

    (void) printf("S=%s, N=%s, R=%s, V=%s, M=%s\n",
        unameuts.sysname,
        unameuts.nodename,
        unameuts.release,
        unameuts.version,
        unameuts.machine
        );

/*  (void) exit(0);  */
    return 0;
  }


/*

       -a, --all = except omit -p and -i
       -p, --processor
       -i, --hardware-platform
       -o, --operating-system
       --help

 */


