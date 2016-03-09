FUNCTION FPNAtXY_Int, X, Y
; PURPOSE:
;  This function returns the 3D footprint function evaluated at the points
;  X and Y.  It is used by the routine INT_2D to integrate the footprint
;  function over user specified X and Y limits.
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
;  SigmaTheta (SWF_Data) - standard deviation of wind direction, deg
;  c     (SWF_Const)
;  p     (SWF_Const)
; OUTPUT:
;  FPNAtXY - value of 3D footprint function at (X,Y)
; AUTHOR: PRI
; DATE: 23/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)
 s = Shape(ZbAtX, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 dZbdx = dZbBydx(L, Zb, z0, p)
 SigY = SigmaY(SigmaTheta, X)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 FPNAtXY = Dy(SigY, Y)*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
 RETURN, DOUBLE(FPNAtXY)
END