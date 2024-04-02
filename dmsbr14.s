*                                                                     *
*                                                                     *
*         Name: dmsbr14.s (CMS name "DMSBR14 S")                      *
*         Date: 2006-Dec-04 (Monday)                                  *
*               A simple assembler program for validation.            *
*               This program is part of the CMS Make package.         *
*      Updated: late 2008 or early 2009
*                                                                     *
*                                                                     *
*lllllll iiiii parm,parm,parm,...      comment
         LA    15,0                    set return code zero
         BR    14                      go back to the caller
*                                                                     *
         DC    C'     '
         DC    C'CMS Make - dmsbr14.s'  human readable eye-catcher
         DC    C'     '
*                                                                     *
         END   ,                       must be the last statement
