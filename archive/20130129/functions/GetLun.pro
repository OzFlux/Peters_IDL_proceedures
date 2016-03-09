FUNCTION GetLun

 Get_Lun, LUN
 Result = FSTAT(LUN)
 IF (Result.Open NE 0) THEN BEGIN
  WHILE (Result.Open NE 0 AND LUN LE 128) DO BEGIN
   LUN = LUN + 1
   Result = FSTAT(LUN)
  ENDWHILE
  IF (Result.Open NE 0 AND LUN EQ 128) THEN $
   STOP,'GetLun: Unable to obtain free unit number'
 ENDIF
 RETURN, LUN

END
