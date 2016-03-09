FUNCTION MOLen, Ta, p, Us, H
; Monin-Obukhov length from air temperature, pressure, friction
; velocity and sensible heat flux.
; INPUT:
;  Ta	- air temperature in C
;  p	- air pressure in hPa
;  Us	- friction velocity, m/s
;  H	- sensible heat flux, W/m2
; OUTPUT:
;  MOLen	- Monin-Obukhov length, m
COMMON Constants
Theta = Theta(Ta, p)
Rho = Rho(Ta, p)
NDTa = SIZE(Ta,/N_DIMENSIONS)
NDp = SIZE(p,/N_DIMENSIONS)
NDUs = SIZE(Us,/N_DIMENSIONS)
NDH = SIZE(H,/N_DIMENSIONS)
IF (NDTa NE NDp OR NDTa NE NDUs OR NDTa NE NDH) THEN $
 STOP,'MOLEN: Ta, p, Us or H have different dimensions'
MOLen = MAKE_ARRAY(N_ELEMENTS(Ta), /FLOAT, VALUE=-9999.)
Index = WHERE(Theta NE -9999. AND Rho NE -9999. AND Us NE -9999. AND H NE -9999. AND (H GT 1 OR H LT -1))
MOLen[Index] = -1.*Theta[Index]*Rho[Index]*cp*(ABS(Us[Index])^3)/(g*k*H[Index])
IF (NDTa EQ 0) THEN RETURN, MOLen[0] ELSE RETURN, MOLen
END
