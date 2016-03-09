PRO PutFC, OutFile, Data, Header, FmtStr

 OutLun = GetLun()
 OPENW, OutLun, OutFile
 PRINTF, OutLun, Header
 IF N_ELEMENTS(FmtStr) NE 0 THEN BEGIN
; Parse the format string to replace 'I', 'F' or 'E' descriptors with
; the 'A' character descriptor and strip out any decimal point
; information.  This produces a format descriptor string that specifies
; the width of the column header fields.
  FSLen = STRLEN(FmtStr)
  i = LONG(0)
  HFStr = ''
  WHILE (i LE FSLen-1) DO BEGIN
   FSChar = STRMID(FmtStr,i,1)
   CASE FSChar OF
   'I': HFStr = HFStr + 'A'
   'F': HFStr = HFStr + 'A'
   'E': HFStr = HFStr + 'A'
   '.': BEGIN
         IF (STRPOS(FmtStr,',',i) NE -1) THEN i = STRPOS(FmtStr,',',i) - 1 ELSE $
         IF (STRPOS(FmtStr,')',i) NE -1) THEN i = STRPOS(FmtStr,')',i) - 1 ELSE $
          STOP,'PutFC: Unrecognised character in format string'
        END
   ELSE: HFStr = HFStr + FSChar
   ENDCASE
   i = i + 1
  ENDWHILE
  PRINTF, OutLun, Data.Labels, FORMAT=HFStr
  FOR i = LONG(0), Data.NRec-1 DO BEGIN
   PRINTF, OutLun, Data.Values[*,i], FORMAT=FmtStr
  ENDFOR
 ENDIF ELSE BEGIN
; No format string was passed to this procedure so simply write
; the data using IDL's default format rules.
  PRINTF, OutLun, Data.Labels
  FOR i = LONG(0), Data.NRec-1 DO BEGIN
   PRINTF, OutLun, Data.Values[*,i]
  ENDFOR
 ENDELSE

 FREE_LUN, OutLun

END
