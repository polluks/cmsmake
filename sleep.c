/*                                                                    *
 *                                                                    *
 *        Name: sleep.c                                               *
 *        Date: 2007 and following                                    *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *                                                                    *
 *                                                                    */

#include "cmsmake.h"

#include <unistd.h>

int main(int argc,char*argv[])
  {
    static  char  *_eye_catcher = "CMS Make - sleep.c";
    if (argc < 2) return 0;
    sleep(atoi(argv[1]));
    return 0;
  }



