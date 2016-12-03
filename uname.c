/*                                                                    *
 *                                                                    *
 *        Name: uname.c                                               *
 *        Date: 2010-May-13 (Thursday, last T320 meeting for JMT)     *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *                                                                    *
 *                                                                    */

#include "cmsmake.h"

#include <unistd.h>
#include <sys/utsname.h>

#define  do_sysname  0x0001
#define  do_nodename  0x0002
#define  do_release  0x0004
#define  do_version  0x0008
#define  do_machine  0x0010
       -s, --kernel-name
       -n, --nodename
       -r, --kernel-release
       -v, --kernel-version
       -m, --machine

int main()
  {
    static  char  *_eye_catcher = "CMS Make - uname.c";
    int  rc;
    struct  utsname  hellouts;

    (void) printf("CMS Make version %s\n",MAKE_VERSION);

    rc = uname(&hellouts);
    if (rc != 0) { (void) perror("uname()"); (void) exit(rc); return rc; }

    (void) printf("OS=%s, R=%s, V=%s, HW=%s\n",
        hellouts.sysname, hellouts.release,
        hellouts.version, hellouts.machine);
    /*  hellouts.nodename  */

    (void) exit(0);
    return 0;
  }





       -a, --all = except omit -p and -i

       -s, --kernel-name
       -n, --nodename
       -r, --kernel-release
       -v, --kernel-version
       -m, --machine

       -p, --processor
       -i, --hardware-platform

       -o, --operating-system

       --help

       --version





