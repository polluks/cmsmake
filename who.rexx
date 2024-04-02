/*
 *        Name: WHO REXX (CMS Pipelines "gem")
 *        Date: 2006-Dec-05 (Tuesday)
 *              2010-May-20 (Thu)                                     *
 *              This program is part of the CMS Make package.         *
 *              2024-03-26 (Tue)                                      *
 */

make_version = "2.0.36"

/* if no other output, attach console */
'STREAMSTATE OUTPUT'
If rc = 12 Then 'ADDPIPE *.OUTPUT: | CONSOLE'
If rc ^= 0 & rc ^= 4 Then Exit rc

/* attach a 'q names' as our input */
'ADDPIPE CP Q NAMES EXT | SPLIT AT /,/ | STRIP' ,
  '| NLOCATE 9.6 / - DSC/' ,
  '| NLOCATE 1.10 /VSM     - /' ,
  '| *.INPUT:'

/* loop through 'q names' and make it look like a 'who' report */
Do Forever
  'PEEKTO RECORD'
  If rc ^= 0 Then Leave
  Parse Var record +0 user +8 "-" term . . "FROM" from
  from = _hostname(from)
  name = _realname(user)
  'OUTPUT' user term name from
  If rc ^= 0 Then Leave
  'READTO'
  If rc ^= 0 Then Leave
End /* Do Forever */

Exit rc * (rc ^= 12)

/* ---------------------------------------------------------------------
 */
_hostname: Procedure
Parse Arg h . , .
If h = "" Then Return h
var = "$" || h

/* if this host is already known then return it as-is */
val = Value(var,,"SESSION NSLOOKUP")
If val = "VAL" Then val = ""
If val ^= "" Then Return val

/* if the remote address is IPv6 then skip the lookup */
If POS(":",h) > 0 Then Do
  val = "[" || h || "]"
  Call Value var, val, "SESSION NSLOOKUP"
  Return val
End

/* try the lookup */
Address "COMMAND" 'PIPE VAR H | HOSTBYADDR | VAR VAL'
If rc ^= 0 Then val = ""
If val = "VAL" Then val = ""

/* wrap failing address in parenthesis */
If rc ^= 0 Then Do
  val = "(" || h || ")"
  Call Value var, val, "SESSION NSLOOKUP"
  Return val
End

/* if we got nuthin then return address as-is */
If val = "" Then Return h

/* otherwise set this for future reference */
Call Value var, val, "SESSION NSLOOKUP"

Return val

/* ---------------------------------------------------------------------
 */
_realname: Procedure
Parse Arg u . , .
If u = "" Then Return Copies(" ",22)
n = "some user"
Address "COMMAND" 'PIPE CMS NAMEFIND :userid' u ':name | VAR N'


l = Length(n)
If l < 22 Then n = n || Copies(" ",22-l)
               Return n


