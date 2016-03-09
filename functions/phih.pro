FUNCTION phih, z, L

  IF (L LT 0) THEN BEGIN
    result = 1.0/(1.0 - 16.0*z/L)^0.5
  ENDIF ELSE BEGIN
    result = (1.0 +  5.0*z/L)
  ENDELSE

  RETURN, result

END
