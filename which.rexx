/*                                                                    *
 *                                                                    *
 *        Name: WHICH REXX (CMS Pipelines gem)                        *
 *        Date: 2010-May-20 (Thu)                                     *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *      Update: 2024-12-21 (Sat)                                      *
 *              add support for CP commands                           *
 *              honor IMPCP (we alreadh handle IMPEX)                 *
 *                                                                    *
 *                                                                    */

make_version = "2.0.39"

/* if no other output then attach console */
'STREAMSTATE OUTPUT'
If rc = 12 Then 'ADDPIPE *.OUTPUT: | CONSOLE'
If rc ^= 0 Then Exit rc

/* parse command-line to know what verb we want and maybe what kind   */
Parse Upper Arg fn ft . '(' opts ')' .
fn = _syn(fn)

which.0 = 0
Select /* ft */

    When ft = "EXEC" Then Do
        'CALLPIPE COMMAND QUERY IMPEX | SPEC FS = F 2 1 | STRIP | VAR IMPEX'
        If impex = "ON" Then ,
        'CALLPIPE COMMAND LISTFILE' fn 'EXEC * | STEM WHICH. APPEND'
        'CALLPIPE COMMAND LISTFILE' fn 'MODULE * | STEM WHICH. APPEND'
    End /* When .. Do */

    When ft = "REXX" Then Do
        'CALLPIPE COMMAND LISTFILE' fn 'REXX * | STEM WHICH. APPEND'
    End /* When .. Do */

    When ft = "" Then Do
        'CALLPIPE COMMAND QUERY IMPEX | SPEC FS = F 2 1 | STRIP | VAR IMPEX'
        If impex = "ON" Then ,
        'CALLPIPE COMMAND LISTFILE' fn 'EXEC * | STEM WHICH. APPEND'
        'CALLPIPE COMMAND LISTFILE' fn 'MODULE * | STEM WHICH. APPEND'
        'CALLPIPE COMMAND QUERY IMPCP | SPEC FS = F 2 1 | STRIP | VAR IMPCP'
        If impcp = "ON" Then Do
        'CALLPIPE CP QUERY COMMANDS' ,
            '| SPLIT' ,
            '| NLOCATE 1.4 /DIAG/' ,
            '| STEM CPC.'
        Do i = 1 to cpc.0
            If cpc.i = fn Then Do
                j = which.0 + 1
                which.j = cpc.i "#CP"    /* mark this as a CP command */
                which.0 = j
            End /* If .. Do */
        End /* Do For */
        End /* If .. Do */
    End /* When .. Do */

End /* Select */

If which.0 > 0 Then Do
    Parse Var which.1 fn ft fm .
    If fm ^= "" Then Do
        fm = Left(fm,1)
        'CALLPIPE COMMAND QUERY ACCESSED' fm '| DROP FIRST | VAR ACC'
        Parse Var acc . . . . fa .
    End ; Else fa = ""
    'OUTPUT' fn ft fm fa
End

Exit rc * (rc ^= 28)


/* ------------------------------------------------------------- SYNONYM
 *  Map the supplied command verb to a synonym if possible.
 *  This routine presumes that USER synonyms take precedence over
 *  SYSTEM synonyms. Would like to get confirmation from an IBMer.
 *  Sadly there is no reliable way to query CP synonyms or abbreviations.
 */
_syn: Procedure

Parse Upper Arg verb . , .

Address "COMMAND" 'PIPE COMMAND QUERY SYNONYM USER' ,
    '| DROP FIRST 3 | STEM SYN.'
If rc ^= 0 Then Return verb

Do i = 1 to syn.0
    Parse Upper Var syn.i vx vl vs .
    l = Length(vs) ; If l = 0 Then l = Length(vl)
    If Abbrev(vl,verb,l) Then Return vx
End /* Do For */

Address "COMMAND" 'PIPE COMMAND QUERY SYNONYM SYSTEM' ,
    '| DROP FIRST 3 | STEM SYN.'
If rc ^= 0 Then Return verb

Do i = 1 to syn.0
    Parse Upper Var syn.i vl vs .
    l = Length(vs)
    If Left(vl,l) = vs Then ,
        If Abbrev(vl,verb,l) Then Return vl
    If verb = vs Then Return vl
End /* Do For */

Return verb


