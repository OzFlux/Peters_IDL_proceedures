PRO GetSer, Data, Series, SerName, First, Last, Nth

  Index = WHERE(Data.Labels EQ SerName, Count)
  IF Count NE 0 THEN BEGIN
   Series = Data.Values(Index,*)
   IF (N_ELEMENTS(First) NE 0) AND $
      (N_ELEMENTS(Last) NE 0)  AND $
      (N_ELEMENTS(Nth) NE 0)   THEN $
       Select, Series, Series, First, Last, Nth
  ENDIF ELSE BEGIN
   ErrText = 'GetSer: "'+SerName+'" does not exist in Data'
   ErrorHandler, ErrText, 0
  ENDELSE

END
