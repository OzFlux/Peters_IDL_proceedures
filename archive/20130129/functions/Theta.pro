FUNCTION Theta, Ta, p
; Potential temperature from air temperature and pressure
; INPUT:
;  Ta	- air temperature in C
;  p	- air pressure in hPa
; OUTPUT:
;  Theta	- potential temperature, K
NDTa = SIZE(Ta,/N_DIMENSIONS)
NDp = SIZE(p,/N_DIMENSIONS)
IF (NDTa NE NDp) THEN STOP,'THETA: Ta and p have different dimensions'
Theta = MAKE_ARRAY(N_ELEMENTS(Ta), /FLOAT, VALUE=-9999.)
Index = WHERE(p NE -9999. AND Ta NE -9999.)
Theta[Index] = (Ta[Index] + 273.15) * (1000. / p[Index]) ^ 0.286
IF (NDTa EQ 0) THEN RETURN, Theta[0] ELSE RETURN, Theta
END
