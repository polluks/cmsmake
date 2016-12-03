/*                                                                    *
 *                                                                    *
 *        Name: hello.c ("Hello, World!")                             *
 *        Date: 2007 and following                                    *
 *              This program is part of the CMS Make package.         *
 *              A simple C program for validation of 'make'.          *
 *                                                                    *
 *                                                                    */

#include "cmsmake.h"

#include <sys/utsname.h>

int main()
  {
    static  char  *_eye_catcher = "CMS Make - hello.c";
    int  rc;
    struct  utsname  hellouts;

    rc = uname(&hellouts);

    (void) printf("Hello, World!\n");

    (void) printf("CMS Make version %s\n",MAKE_VERSION);

    (void) printf("OS=%s, R=%s, V=%s, HW=%s\n",
        hellouts.sysname, hellouts.release,
        hellouts.version, hellouts.machine);
    /*  hellouts.nodename  */

    (void) exit(0);
    return 0;
  }



