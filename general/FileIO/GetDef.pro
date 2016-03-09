PRO GetDef, Lun, Defn

    Line = ''
    WHILE NOT EOF(Lun) DO BEGIN
     READF, Lun, FORMAT='(A)', Line
     Line = CleanString(Line)
     Chr = STRMID(Line,0,1)
     Len = STRLEN(Line)
     IF Chr NE ';' AND Chr NE 'c' AND Chr NE 'C' AND Chr NE '!' AND Len GT 0 THEN BEGIN
      IF STRPOS(STRLOWCASE(Line),'[end]') NE -1 THEN GOTO, Finish
      Parts = STR_SEP(Line,' ')
      CASE STRLOWCASE(Parts(0)) OF
       'type': Defn.Type = Parts(1)
       'root': Defn.Root = Parts(1)
       'stat': Defn.Stat = Parts(1)
      ELSE: PRINT, 'GetDef: Unrecognised keyword'
      ENDCASE
     ENDIF
    ENDWHILE

Finish:
END
