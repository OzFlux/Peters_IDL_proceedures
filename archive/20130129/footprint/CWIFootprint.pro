FUNCTION CWIFootprint, zm, z0, L, Us, MaxCWgt

 MZb = 10.*zm
 NZb = 500
 N = 0
DOH94:
 N = N + 1
 FPN = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /H94)
 dX = Centreddifference(FPN.Distance,INDGEN(N_ELEMENTS(FPN.Distance)))
 IF (TOTAL(FPN.Weights*dX) LT MaxCWgt) THEN BEGIN
  IF (N GE 20) THEN STOP,'CWIFootprint: More than 20 calls to XWindIntFPN'
  MZb = 1.25*MZb
  NZb = 1.25*NZb
  GOTO, DOH94
 ENDIF
 RETURN, FPN

END