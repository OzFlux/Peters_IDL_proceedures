FUNCTION CentredDifference, X, Y

 SX = SIZE(X)
 IF (SX[0] NE 1) THEN STOP, $
  'CENTREDDIFFERENCE: Input X is not a 1D array'
 SY = SIZE(Y)
 IF (SY[0] NE 1) THEN STOP, $
  'CENTREDDIFFERENCE: Input Y is not a 1D array'
 IF (SX[1] NE SY[1]) THEN STOP, $
  'CENTREDDIFFERENCE: Input X and Y arrays are different lengths'
 N = SX[1]
 CD = FLTARR(N)
 CD[0] = (X[1]-X[0])/(Y[1]-Y[0])
 FOR i=1,N-2 DO CD[i] = (X[i+1]-X[i-1])/(Y[i+1]-Y[i-1])
 CD[N-1] = (X[N-1]-X[N-2])/(Y[N-1]-Y[N-2])
 RETURN, CD

END