PRO GetRun, DefLun, Runs
    Line = ''
    RDmy = 1.0
    i = 0
    READF, DefLun, FORMAT='(A)', Line	; Read the header line
    WHILE NOT EOF(DefLun) DO BEGIN
     READF, DefLun, FORMAT='(A)', Line
     Line = CleanString(Line)
     Chr = STRMID(Line,0,1)
     Len = STRLEN(Line)
     IF Chr NE ';' AND Chr NE 'c' AND Chr NE 'C' AND Chr NE '!' AND Len GT 0 THEN BEGIN
      IF STRPOS(STRLOWCASE(Line),'[end]') NE -1 THEN GOTO, Finish
      Parts = STR_SEP(Line,' ')
      Runs.Date(i) = Parts(0)
      Runs.ACDay(i) = Parts(1)
      Runs.ID(i) = Parts(2)
      READS, Parts(3), RDmy
      Runs.STime(i) = RDmy
      READS, Parts(4), RDmy
      Runs.FTime(i) = RDmy
      Runs.Src(i) = Parts(5)
      i = i + 1
     ENDIF
    ENDWHILE
Finish:
    Runs.No = i
END
