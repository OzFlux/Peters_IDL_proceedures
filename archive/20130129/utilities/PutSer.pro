PRO PutSer, Data, Series, SerLab

  IF N_TAGS(Data) EQ 0 THEN BEGIN
   NS = 1
   NR = N_ELEMENTS(Series)
   Data = {Values:FLTARR(NS,NR),NSer:LONG(0),NRec:LONG(0),Labels:STRARR(NS)}
   Data.Values[0,*] = Series[*]
   Data.NSer = NS
   Data.NRec = NR
   Data.Labels[0] = STRTRIM(SerLab,2)
  ENDIF ELSE BEGIN
   IF N_ELEMENTS(Series) NE Data.NRec THEN BEGIN
    SRChar = STRCOMPRESS(STRING(N_ELEMENTS(Series)))
    DRChar = STRCOMPRESS(STRING(Data.NRec))
    ErrText = 'PutSer: "'+SerLab+'" has'+SRChar+' elements but Data has'+DRChar
    ErrorHandler, ErrText, 1
   ENDIF
   NS = Data.NSer + 1
   NR = Data.NRec
   Temp = {Values:FLTARR(NS,NR),NSer:Long(0),NRec:LONG(0),Labels:STRARR(NS)}
   Temp.Values[0:NS-2,*] = Data.Values[0:NS-2,*]
   Temp.Labels[0:NS-2] = Data.Labels[0:NS-2]
   Temp.Values[NS-1,*] = Series
   Temp.Labels[NS-1] = STRTRIM(SerLab,2)
   Temp.NSer = NS
   Temp.NRec = NR
   Data = 0
   Data = Temp
   Temp = 0
  ENDELSE

END
