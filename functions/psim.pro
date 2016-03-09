FUNCTION psim, z, L

  IF (L LT 0) THEN BEGIN
    x = (1.0 - 16.0*z/L)^0.25
    result = 2.0*ALOG((x+1.0)/2.0)+ALOG((x^2+1)/2.0)-2.0*ATAN(x)+!PI/2.0
  ENDIF ELSE BEGIN
    result = -5.0*z/L
  ENDELSE

  RETURN, result

END