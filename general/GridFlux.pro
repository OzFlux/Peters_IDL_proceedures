PRO GridFlux, DefFIle

; Define constants.
  Constants

; General definitions.
  LastB1File = 'Empty'

; Read the definitions file,
  GetDef, DefFile, Gen, Runs

; Loop over runs defined in DefFile.
  FOR Run = 0, Runs.No-1 DO BEGIN

; Read the data file.
   B1File = Gen.Root+'DAY'+Runs.ACDay[Run]+'\3F_TRN.'+Runs.Src[Run]
   IF B1File NE LastB1File THEN BEGIN
    GetB1, B1File, Data
    GetSer, Data, atagt, 'atag', 0, 0, 1
    GetSer, Data, AMGEt, 'AMGE', 0, 0, 1
    GetSer, Data, AMGNt, 'AMGN', 0, 0, 1
    Data = 0
    LastB1File = B1File
   ENDIF
   Index = WHERE(atagt GE Runs.STime[Run] AND atagt LE Runs.FTime[Run])
   IF Run EQ 0 THEN BEGIN
    atag = atagt[Index]
    AMGE = AMGEt[Index]
    AMGN = AMGNt[Index]
   ENDIF ELSE BEGIN
    Join, atag, atag, atagt[Index]
    Join, AMGE, AMGE, AMGEt[Index]
    Join, AMGN, AMGN, AMGNt[Index]
   ENDELSE

  ENDFOR

END