FUNCTION FPNAtY0_Neg, X
; PURPOSE:
;  This function returns the negative of the footprint function
;  evaluated at Y = 0 for a range of X values.  It is used to
;  determine the maximum of the footprint function and the location
;  of the maximum.  The routine that performs the optimisation,
;  Golden, searches for a minimum, hence the use of the negative
;  of the footprint function in this routine (searching for a
;  minimum in the negative of a function is equivalent to
;  searching for a maximum in the function itself).
;
;  Note that the function is normalised by dividing by the maximum
;  value of the function (in FVal).  This is done to avoid problems
;  with round-off error encountered when the value of the function
;  gets small (FMax~4E-5).
; INPUT (EXPLICIT):
;  X - upwind distance at which to evaluate the negative of the footprint
;      function
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data)  - mean plume height, m
;  XAtZb (SWF_Data)  - upwind distances corresponding to ZbAtX, m
;  zm    (SWF_Data)  - measurement height, m
;  z0    (SWF_Data)  - roughness length, m
;  L     (SWF_Data)  - Monin-Obukhov length, m
;  Ub    (SWF_Data)  - mean wind speed at zm, m/s
;  Us    (SWF_Data)  - friction velocity, m/s
;  SigmaTheta (SWF_Data) - standard deviation of wind direction, deg
;  FVal  (SWF_Const) - value used to normalise the function so that the
;                      minimum value of CWIF_Neg is close to -1, this is
;                      done to avoid round-off errors
;  p     (SWF_Const)
;  c     (SWF_Const)
; OUTPUT:
;  -1*CWIF/FVal - returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zbx = Zbar(ZbAtX, XAtZb, X)
 s = Shape(Zbx, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 SigY = SigmaY(SigmaTheta, X)
 dZbdx = dZbBydx(L, Zbx, z0, p)
 Uzb = Uzbar(Zbx, Us, L, z0, c)
 RETURN, DOUBLE(-1.*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zbx))^s)/(Zbx^2*Uzb)/(FVal*r2PI*SigY))
END