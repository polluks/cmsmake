/*                                                                    *
 *                                                                    *
 *        Name: MAKE REXX (rules processor for CMS)                   *
 *        Date: 2006-May-23 (Monday)                                  *
 *              This program is part of the CMS Make package.         *
 *                                                                    *
 *                                                                    */

make_version = "2.0.31"
Numeric Digits 16

/* if no other output, attach console */
'STREAMSTATE OUTPUT'
If rc = 12 Then 'ADDPIPE *.OUTPUT: | CONSOLE'
If rc ^= 0 Then Exit rc

/* default all rules, variables, and dependencies to NULLs */
mak. = '00'x ;  dep. = "" ;  var. = "" ;  _default = ""

/* extract username and hostname and set as make-space variables */
Parse Value tolower(Diag(08,'Q USERID')) With vmid . host . '15'x .
var.USER = vmid
var.USERNAME = vmid
var.LOGNAME = vmid
var.HOSTNAME = host

/* some initial values */
mfn = "_default.cmsmake"
Address "COMMAND" 'STATE' vmid 'CMSMAKE'
If rc = 0 Then mfn = vmid || ".cmsmake"
vars = ""

/* parse command-line options and variables */
Parse Arg args
Parse Var args arg1 .
Do While Left(arg1,1) = "-" | POS("=",arg1) > 0
  Parse Var args . args
/* If Left(arg1,1) = "-" Then Upper arg1 -- why??? */
  Select
    When Abbrev("-f",arg1,2) Then Parse Var args mfn args
    When Abbrev("--version",arg1,5) Then Do
      Say "CMS Make" make_version
      Exit
    End
    When POS("=",arg1) > 0 Then vars = vars arg1
    Otherwise Do
      Address "COMMAND" 'XMITMSG 3 ARG1 (ERRMSG'
      Exit 24
    End
  End /* Select */
  Parse Var args arg1 .
End

/* do we have a makefile name? */
If mfn = "" Then Do
  Address "COMMAND" 'XMITMSG 1 (ERRMSG'
  Exit 24
End

/* load customizations as "generic" */
'ADDPIPE < _GENERIC CMSMAKE | *.INPUT:'
If rc ^= 0 Then Exit rc

/* parse rules file name */
Parse Upper Var mfn mfn '.' mft '.' .
If mft = "" Then mft = "CMSMAKE"

/* try and attach the specified rules file */
'ADDPIPE (END !) *.INPUT: | F: FANIN | *.INPUT:' ,
           '! <' mfn mft '| F:'
If rc ^= 0 Then Exit rc

/* set some variables which can be overridden later */
var.MAKELEVEL = 0
$ = "MAKE_VERSION"
var.$ = make_version
var.MAKECMDGOALS = args
var.MAKEFILE = tolower(mfn||"."||mft)
var.MAKEFILES = var.MAKEFILE
var.MAKEFILE_LIST = var.MAKEFILE

/* set hosttype from CMS level to indicate architecture */
'CALLPIPE COMMAND Q CMSLEVEL | SPEC W 1 NW' ,
  '| CHANGE #/## | XLATE UPPER | VAR TYPE'
Select /* qcms */
  When type = "CMS" Then type = "s390"
  When type = "ZCMS" Then type = "s390x"
  Otherwise Address "COMMAND" 'XMITMSG 201 TYPE (ERRMSG'
End
var.HOSTTYPE = type

/* tabs to blanks, remove comments, and strip trailing blanks */
'ADDPIPE *.INPUT: | CHANGE' '0005004000'x ,
  '| NLOCATE 1.1 /#/ | NLOCATE 1.1 /*/' ,
  '| STRIP TRAILING | LOCATE 1.1 | *.INPUT:'
If rc ^= 0 Then Exit rc

/* collect rules, variables, and whatever */
targets = ""
Do Forever

  /* examine an input record, but don't consume it yet */
  'PEEKTO RECORD'
  If rc ^= 0 Then Leave

  /* concatenate continuations */
  Do While Right(record,1) = "\"
    _first = Left(record,Length(record)-1)
    'READTO'
    If rc ^= 0 Then Leave
    'PEEKTO RECORD'
    If rc ^= 0 Then Leave
    record = _first || record
  End

  /* pluck out a key char, either colon or equals sign */
  k = Verify(record,":=","M")
  If k > 0 Then k = Substr(record,k,1)
           Else k = ""

  /* switch based on key char or other record characteristics */
  Select
    When Left(record,1) = " " Then Do
      If targets = "" Then Do
        Say "*** commands commence before first target.  Stop."
        Exit 32
      End
      /* loop here for multiple targets support */
      target_ = targets
      Do While target_ ^= ""
        Parse Var target_ target target_
        target = Strip(target)
        If mak.target = '00'x Then mak.target = ""
        mak.target = mak.target || '15'x || record
      End /* Do While */
    End /* When .. Do */
    When k = "=" Then Do
      Parse Var record var '=' val
      var = Strip(var) ;  val = Strip(val)
      var.var = val
    End /* When .. Do */
    When k = ":" Then Do
      Parse Var record targets ":" deps ";" rule
      /* loop here for multiple targets support */
      target_ = targets
      Do While target_ ^= ""
        Parse Var target_ target target_
        target = Strip(target)
        dep.target = deps
        mak.target = Translate(rule,'15'x,";")
        If _default = "" Then Parse Var target _default .
      End /* Do While */
    End /* When .. Do */
    Otherwise Do
/*    Address "COMMAND" 'XMITMSG 3402 RECORD (ERRMSG'
      Exit 36    */
      Say "*** missing separator.  Stop."
      Exit 32
    End /* Otherwise Do */
  End /* Select */

  /* now consume the record from input */
  'READTO'
  If rc ^= 0 Then Leave
End

/* let command-line variables override rules file variables */
Do While vars ^= ""
  Parse Var vars var vars
  Parse Var var var '=' val
  var = Strip(var) ;  val = Strip(val)
  var.var = val
End /* Do While */

/* do it */
args = Strip(args)
If args = "" Then Parse Value make_run(_default,0) With _rc _rs
             Else Parse Value make_run(args,0) With _rc _rs
If _rs ^= "" Then ,
  'CALLPIPE VAR _RS | SPLIT AT STRING x15 | *.OUTPUT:'

/* get outta here! */
Exit _rc


/* ---------------------------------------------------------------------
 *  Pursue the goals specified on the command line or the default.
 */
make_run: Procedure     Expose mak. dep. var.
Parse Arg t , l , .
If ^Datatype(l,'W') Then ,
  Return -1 "*** internal - level is not numeric"
If Words(t) > 1 Then Do
  Do While t ^= ""
    Parse Var t _t t
    Parse Value make_run(_t,l) With rc rs
    If rc ^= 0 Then Return rc rs
  End /* Do While */
  Return 0
End /* If .. Do */
If Words(t) < 1 Then ,
  Return -1 "*** internal - zero or negative targets"
d = Strip(dep.t)
s = Strip(mak.t)

st = make_stamp(t)
If st = 0 Then If mak.t = '00'x Then Return 32 ,
  "*** No rule to make target `" || t || "'.  Stop."

domake = (st = 0)
d = make_subst(Strip(d),t) ;  ds = d
Do While d ^= ""
  Parse Var d d1 d
  Parse Value make_run(d1,l+1) With rc rs
  If rc ^= 0 Then Return rc rs
  If make_stamp(d1) > st Then domake = 1
End

If domake = 0 Then Return 0 "`" || t || "' is up to date."
/*  "Nothing to be done for `" || t || "'."  */

s = make_subst(Strip(s,,'15'x),t,ds)
Do While s ^= ""
  Parse Var s s1 '15'x s
  s1 = Strip(s1) ;  mute = 0 ;  okay = 0 ;  skip = 0
  Do Forever ; Select
    When Left(s1,1) = "@" Then Do
      mute = 1
      s1 = Substr(s1,2)
    End
    When Left(s,1) = "-" Then Do
      okay = 1
      s1 = Substr(s1,2)
    End
    Otherwise Leave
  End ; End
  If Left(s1,1) = "#" Then skip = 1
  /* report with indentation depending on our depth ... */
  If ^mute Then Say Copies(" ",l) || s1
  If skip Then Iterate   /* might be echoed, but is not performed */
  /* ... and execute this step */
  Parse Value make_step(s1) With rc rs
  If ^okay Then If rc ^= 0 Then Return rc "*** [" || t || "] Error" rc
End

Return 0


/* ---------------------------------------------------------------- STEP
 *  Execute one step in a recipe.
 */
make_step: Procedure    Expose var.
Parse Arg args
Parse Upper Var args arg1 .
Parse Var args . argn
Select
  When arg1 = "ECHO" Then Return make_echo(argn)
  When arg1 = "TEST" Then Return make_test(argn)
  When arg1 = "CMS" Then Return make_cms(argn)
  When arg1 = "HCP" Then Return make_hcp(argn)
  When arg1 = "SH" Then Return make_sh(argn)
  Otherwise Return make_cms(arg1 argn)
End
Return -1 "*** internal - nothing selected for a command step"


/* --------------------------------------------------------------- STAMP
 *  Return a relative time stamp.  (Not reusable outside this context.)
 */
make_stamp: Procedure
Parse Upper Arg file . , .
file = file || ".#"
'CALLPIPE VAR FILE | XLATE UPPER' ,
  '| SPEC WS . /LISTFILE/ NW W 1 NW W 2 NW /(ISODATE/ NW' ,
  '| COMMAND | DROP FIRST | SPEC W 8 1-10 W 9 11-18' ,
  '| CHANGE /-// | CHANGE /:// | CHANGE / /0/ | VAR N'
If rc ^= 0 Then Return 0
           Else Return n


/* ------------------------------------------------------------------ SH
 *  Run a shell command via OpenVM (which is otherwise not required).
 */
make_sh: Procedure      Expose var.
sh = var.SHELL
bfsr = var.BFSROOT
'CALLPIPE VAR SH | BFSSTATE | VAR RS'
If rc = 28 Then ,
'CALLPIPE VAR BFSR' ,
  '| SPEC #OPENVM MOUNT# NW W 1 NW #/# NW | CMS | VAR RS'
If rc ^= 0 Then Return rc rs
Parse Arg args
Address "CMS" 'OPENVM RUN' sh args
Return rc


/* ----------------------------------------------------------------- CMS
 *  Run a CMS command.
 */
make_cms: Procedure
Parse Arg args
If Left(Strip(args),1) = "'" Then Parse Var args . "'" args "'" .
Else ,
If Left(Strip(args),1) = '"' Then Parse Var args . '"' args '"' .
'CALLPIPE VAR ARGS | CMS | *.OUTPUT:'
Return rc


/* ----------------------------------------------------------------- HCP
 *  Run a CP command.
 */
make_hcp: Procedure
Parse Arg args
If Left(Strip(args),1) = "'" Then Parse Var args . "'" args "'" .
Else ,
If Left(Strip(args),1) = '"' Then Parse Var args . '"' args '"' .
'CALLPIPE VAR ARGS | CP | *.OUTPUT:'
Return rc


/* ---------------------------------------------------------------- PIPE
 *  Run a Pipeline.
 */
make_pipe: Procedure
Parse Arg args
If Left(Strip(args),1) = "'" Then Parse Var args . "'" args "'" .
Else ,
If Left(Strip(args),1) = '"' Then Parse Var args . '"' args '"' .
'CALLPIPE *.INPUT: |' args '| *.OUTPUT:'
Return rc


/* ---------------------------------------------------------------- TEST
 *  Test a condition.
 */
make_test: Procedure
Return 0


/* ---------------------------------------------------------------- ECHO
 *  Echo some line of text to the output.
 */
make_echo: Procedure
Parse Arg args
If Left(Strip(args),1) = "'" Then Parse Var args . "'" args "'" .
Else ,
If Left(Strip(args),1) = '"' Then Parse Var args . '"' args '"' .
'CALLPIPE VAR ARGS | *.OUTPUT:'
Return rc


/* --------------------------------------------------------------- SUBST
 *  Perform substitution.  Handle special cases automatically.
 *  @ == current target (supplied as an argument)
 *  < == first dependency
 *  + == all dependencies
 */
make_subst: Procedure Expose var.
Parse Arg i , t , d , .
o = ""
Do While POS("$",i) > 0
  Parse Var i p"$"i
  If Left(i,1) = "(" Then Parse Var i "("v")"i
                     Else Do
    v = Left(i,1)
    i = Substr(i,2)
  End /* Else Do */
  Select
    When v = "@" Then p = p||t
    When v = "<" Then p = p||Word(d,1)
    When v = "+" Then p = p||d
    When v = ".VARIABLES" Then Do
      'CALLPIPE REXXVARS | DROP FIRST' ,
        '| CHANGE 1.2 /n // | CHANGE 1.2 /v // | JOIN 1 /=/' ,
        '| LOCATE 1.4 /VAR./ | CHANGE 1.4 /VAR.//' ,
        '| SPEC FS = F 1 1 | JOIN * / / | VAR VL'
      p = p||vl
    End /* When .. Do */
    When v = ".LIBPATTERNS" Then nop
    /* .LIBPATTERNS=lib%.so lib%.a */
    Otherwise         p = p||var.v
  End /* Select */
  o = o||p
End
Return o||i


/* ------------------------------------------------------------- TOLOWER
 *  function name here should be obvious
 */
tolower: Procedure
Parse Arg i , .
Return Translate(i,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")


