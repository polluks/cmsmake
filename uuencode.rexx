/*
 *
 *        Name: uuencode.rexx
 *        Date: 2007-Apr-15 (Sunday)
 *
 */

/* set some initial values */
mime = 0
mode = "644"
ex64 = ""

Parse Arg args '(' . ')' .
/* parse command line arguments */
Do While Left(args,1) = "-"
  Parse Var args argo args
  Select
    When Abbrev("-m",argo,2) Then mime = 1
    Otherwise Do
      Address "COMMAND" 'XMITMSG 3 ARGO (ERRMSG'
      Exit 24
    End /* Otherwise Do */
  End /* Select */
End /* Do While */

/* the "-m" option is required in this implementation */
If ^mime Then Do
  Address "COMMAND" 'XMITMSG 384 (ERRMSG'
  Exit 24
End /* If .. Do */

/* determine input file and named output file */
Parse Var args file name .
If file = "" Then Do
  Address "COMMAND" 'XMITMSG 386 (ERRMSG'
  Exit 24
End /* If .. Do */
If name = "" Then name = file
             Else Do
  Parse Upper Var file fn "." ft "."
  'ADDPIPE <' fn ft '| *.INPUT:'
  If rc ^= 0 Then Exit rc
End /* If .. Do */

/* look for a suitable Base 64 encoder */
Address "COMMAND" 'STATE ENBASE64 REXX *'
If rc = 0 Then ex64 = "ENBASE64"
Address "COMMAND" 'STATE 64ENCODE REXX *'
If rc = 0 Then ex64 = "64ENCODE"
If ex64 = "" Then Do
  Address "COMMAND" 'XMITMSG 002 (ERRMSG'
/* Address "COMMAND" 'XMITMSG 002 "64ENCODE REXX" (ERRMSG' */
  Exit 28
End /* If .. Do */

/* now do the encoding */
'OUTPUT' "begin-base64" mode name
'CALLPIPE *.INPUT: |' ex64 '| *.OUTPUT:'
'OUTPUT' "===="


