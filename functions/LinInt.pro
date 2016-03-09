FUNCTION LinInt, InY, InX, OutX

 NInX = N_ELEMENTS(InX)
 NInY = N_ELEMENTS(InY)
 IF (NInX NE NInY) THEN STOP,'Trans: Input series are different lengths'

 Ind = WHERE(InY NE -9999.,NInd)
 IF (NInd NE NInY) THEN BEGIN
  OKFrac = FLOAT(NInd)/FLOAT(NInY)
  IF (OKFrac LT 0.9) THEN STOP,'Trans: More than 10% of input series missing'
  InY = INTERPOL(InY[Ind], InX[Ind], InX)
 ENDIF

 OutY = INTERPOL(InY, InX, OutX)
 Ind = WHERE(OutX LT InX[0] OR OutX GT InX[NInX-1], NInd)
 IF (NInd NE 0) THEN OutY[Ind] = -9999.

 RETURN, OutY

END