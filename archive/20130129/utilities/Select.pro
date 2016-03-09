pro Select, OutSer, InSer, First, Last, Nth

; Procedure to pick a subset of elements from a series
    NInSer = N_ELEMENTS(InSer)
    IF (First LE 0)      THEN First = 0
    IF (Last LE 0)       THEN Last  = NInSer - 1
    IF (Last  GT NInSer) THEN Last  = NInSer - 1
    IF (First GE Last)   THEN BEGIN
     PRINT, 'Select : First GE Last'
     First = 0
     Last  = NInSer
    ENDIF
    IF (N_ELEMENTS(Nth) EQ 0) THEN Nth = 1
    IF (Nth LT 1)             THEN Nth = 1
    IF (Nth GT FIX(NInSer/2)) THEN Nth = 1

    OutSer = InSer(First:Last)
    NumEle = N_ELEMENTS(OutSer)
    Index  = FINDGEN(NumEle)
    Index  = Index*Nth
    Index  = Index(WHERE(Index LE NumEle))
    OutSer = OutSer(Index)

end

