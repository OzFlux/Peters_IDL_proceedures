FUNCTION CWIF, X
; PURPOSE:
;  This function returns the cross-wind integrated footprint at X and is
;  used by QROMO to calculate the integral of the cross-wind integrated
;  footprint over a specified range of downwind distances.
;  The approximate expression for the cross-wind integrated footprint
;  given in Horst and Weil 1994 is used.
; INPUT (EXPLICIT):
;  X - upwind distance, scalar or 1D array, m
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data) - Zbar at upwind distances XAtZb, m
;  XAtZb (SWF_Data) - upwind distances at which ZbAtX defined, m
;  zm    (SWF_Data) - observation height, m
;  z0    (SWF_Data) - roughness length, m
;  L     (SWF_Data) - Monin-Obukhov length, m
;  Ub    (SWF_Data) - mean wind speed at observation height zm, m/s
;  Us    (SWF_Data) - friction velocity, m/s
;  c     (SWF_Const)
;  p     (SWF_Const)
; OUTPUT:
;  CWIF - value of cross-wind integrated footprint function at X
; AUTHOR: PRI
; DATE: 23/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)		; Interpolate ZbAtX from XAtZb to X
 s = Shape(Zb, z0, L, c)		; Calculate shape parameter
 A = AConst(s, /H94)			; Calculate A parameter
 b = BConst(s, /H94)			; Calculate b parameter
 dZbdx = dZbBydx(L, Zb, z0, p)	; Rate of change in Zbar with X at X
 Uzb = Uzbar(Zb, Us, L, z0, c)	; Mass-weighted plume advection speed
 RETURN, dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
END