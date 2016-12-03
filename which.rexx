/*                                                                    *
 *                                                                    *
 *        Name: WHICH REXX (CMS Pipelines gem)                        *
 *        Date: 2010-May-20 (Thu)                                     *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *                                                                    */

make_version = "2.0.30"

/* if no other output, attach console */
'STREAMSTATE OUTPUT'
If rc = 12 Then 'ADDPIPE *.OUTPUT: | CONSOLE'
If rc ^= 0 Then Exit rc

/* parse command-line to know which kind of verb we are after */
Parse Upper Arg fn ft . '(' opts ')' .

which.0 = 0
Select /* ft */
  When ft = "EXEC" Then Do
    'CALLPIPE COMMAND Q IMPEX | SPEC FS = F 2 1 | STRIP | VAR IMPEX'
    If impex = "ON" Then ,
    'CALLPIPE COMMAND LISTFILE' fn 'EXEC * | STEM WHICH. APPEND'
    'CALLPIPE COMMAND LISTFILE' fn 'MODULE * | STEM WHICH. APPEND'
  End /* When .. Do */
  When ft = "REXX" Then Do
    'CALLPIPE COMMAND LISTFILE' fn 'REXX * | STEM WHICH. APPEND'
  End /* When .. Do */
  When ft = "" Then Do
    'CALLPIPE COMMAND LISTFILE' fn 'REXX * | STEM WHICH. APPEND'
  End /* When .. Do */
End /* Select */

If which.0 > 0 Then Do
  Parse Var which.1 fn ft fm .
  fm = Left(fm,1)
  'CALLPIPE COMMAND Q ACCESSED' fm '| DROP FIRST | VAR ACC'
  Parse Var acc . . . . fa .
  'OUTPUT' fn ft fm fa
End

Exit rc * (rc ^= 28)




