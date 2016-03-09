FUNCTION CWIF_Root, X
; PURPOSE:
;  This function returns the value of the cross-wind integrated
;  footprint function at the upwind distance X (CWIF) minus a
;  specified function value, FVal.  It is used by the root finding
;  function (Rtbis) to estimate the upwind distances corresponding
;  to particular values of the cross-wind integrated footprint
;  function.
; INPUT (EXPLICIT):
;  X - upwind distance at which to evaluate the cross-wind
;      integrated footprint function
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data)  - mean plume height, m
;  XAtZb (SWF_Data)  - upwind distances corresponding to ZbAtX, m
;  zm    (SWF_Data)  - measurement height, m
;  z0    (SWF_Data)  - roughness length, m
;  L     (SWF_Data)  - Monin-Obukhov length, m
;  Ub    (SWF_Data)  - mean wind speed at zm, m/s
;  Us    (SWF_Data)  - friction velocity, m/s
;  FVal  (SWF_Const) - value to be subtracted from the calculated footprint
;                      function, this is the function value for which RTBIS
;                      will determine the X location
;  p     (SWF_Const)
;  c     (SWF_Const)
; OUTPUT:
;  CWIF-FVal - returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 IF (X GT 0.0) THEN BEGIN
  Zb = Zbar(ZbAtX, XAtZb, X)
  s = Shape(Zb, z0, L, c)
  A = AConst(s, /H94)
  b = BConst(s, /H94)
  dZbdx = dZbBydx(L, Zb, z0, p)
  Uzb = Uzbar(Zb, Us, L, z0, c)
  CWIF = dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
 ENDIF ELSE BEGIN
  CWIF = 0
 ENDELSE
 RETURN, CWIF-FVal
END