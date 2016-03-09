FUNCTION Rho, Ta, p
; Dry air density from temperature and pressure
; INPUT:
;  Ta	- air temperature in C
;  p	- air pressure in hPa
; OUTPUT:
;  Rho	- dry air density, kg/m3
COMMON Constants
NDTa = SIZE(Ta,/N_DIMENSIONS)
NDp = SIZE(p,/N_DIMENSIONS)
IF (NDTa NE NDp) THEN STOP,'RHO: Ta and p have different dimensions'
Rho = MAKE_ARRAY(N_ELEMENTS(Ta), /FLOAT, VALUE=-9999.)
Index = WHERE(p NE -9999. AND Ta NE -9999.)
Rho[Index] = p[Index] * 100. / (Rd * (Ta[Index] + 273.15))
IF (NDTa EQ 0) THEN RETURN, Rho[0] ELSE RETURN, Rho
END
