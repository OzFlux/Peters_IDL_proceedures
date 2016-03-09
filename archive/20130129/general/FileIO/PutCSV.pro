PRO PutCSV, OutFile, Data, Header, FmtStr

; Writes data to a comma separated values file.
 OutLun = GetLun()
 OPENW, OutLun, OutFile
 PRINTF, OutLun, Header
 Tmp = Data.Labels[0]
 IF (Data.NSer GE 2) THEN BEGIN
  FOR i = 1, Data.NSer-1 DO BEGIN
   Tmp = Tmp + ',' + Data.Labels[i]
  ENDFOR
 ENDIF
 PRINTF, OutLun, Tmp

 FOR i = 0, Data.NRec-1 DO BEGIN
  Tmp = BYTE(CleanString(STRING(Data.Values[*,i], FORMAT=FmtStr)))
  Tmp(WHERE(Tmp EQ 32)) = 44
  PRINTF, OutLun, STRING(Tmp)
 ENDFOR

 FREE_LUN, OutLun

END
