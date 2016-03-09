FUNCTION XWindIntFPN, zm, z0, L, ustar, MZb, NZb, K97=K97, H94=H94, XCT=XCT, Normalise=Normalise
; PURPOSE:
;  This function returns the cross-wind integrated source-area weights
;  as a function of upwind distance for a given measurement height and
;  and stability.
; INPUTS:
;  zm - measurement height, m (scalar)
;  z0 - roughness height, m (scalar)
;  L  - Monin-Obukhov length, m (scalar)
;  ustar - friction velocity, m/s (scalar)
;  MZb - maximum value for Zbar, m (scalar)
;  NZb - number of points at which to calculate Zbar and XAtZb
; OUTPUTS:
;  FPN - anonymous structure containing the following fields:
;   FPN.Weights - cross-wind integrated source-area weights, (1D array)
;   FPN.Distance - upwind distances at which FPN.Weights calculated, (1D array)
; DATE: 20/11/2002
; AUTHOR: PRI
; *** Declare the constants common block.
 COMMON Constants
 COMMON UbCWIC, s, A, b, ZbAtX, Uzb, FVel, RLen, MOLen
; *** Define various local constants.
 p = 1.55		; PConst(s)										;1.55 at s=1.5
 c = 0.63		; b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
; *** Clip the value of L to make believe that the aircraft is
; *** in the surface layer.  We will use a very generous definition
; *** of the depth of the surface layer.
 IF (zm/L LT -5.0) THEN L = -zm/5.0
; *** Calculate Zbar using the analytic expression for x(zbar) from
; *** HW94 Eqns A4 and A10.
; *** First, we create a series of Zbar values ranging from z0 to
; *** ten the measurement height, 10*zm, with 200 values.
 Zb = (FINDGEN(NZb)*MZb/(NZb-1)) + z0
 PSIFnZ0 = PSIFnZ(L, z0, z0, p)		;PSIFnZ returns DOUBLE
 X = z0*FLOAT(PSIFnZ(L, Zb, z0, p) - PSIFnz0)
 Zb = Zb[WHERE(X GT 0.0)]
 X = X[WHERE(X GT 0.0)]
 NEle = N_ELEMENTS(X)
 dZbdx = dZbBydx(L, Zb, z0, p)
; *** Define a structure to hold the footprint weights and distances.
 NEle = N_ELEMENTS(X)
 FPN = {Weights:FLTARR(NEle),Distance:FLTARR(NEle),Zb:FLTARR(NEle)}
 FPN.Distance = X
 FPN.Zb = Zb
; *** Calculate the average of the wind speed between the ground and Zbar.
; *** Calculate
 CASE 1 OF
  KEYWORD_SET(K97): BEGIN
    Uzb = Uzbar(Zb, ustar, L, z0, c)
    s = 1.5	;Shape(Zb, z0, L, c)
    A = AConst(s, /K97)
    B = BConst(s, /K97)
    SigZ = SigmaZ(Zb, s)
    Tmp = ustar*k*s*zm^s*EXP(-(zm/(B*SigZ))^s)
    FPN.Weights = Tmp/(phih(zm,L)*(B*SigZ)^s*A*SigZ*Uzb)
   END
  KEYWORD_SET(H94): BEGIN
    Uzb = Uzbar(Zb, ustar, L, z0, c)
    s = Shape(Zb, z0, L, c)
    A = AConst(s, /H94)
    b = BConst(s, /H94)
    Ub = (ustar/k)*(ALOG(zm/z0)-Psim(zm,L))
    Tmp = dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)
    FPN.Weights = Tmp/(Uzb*Zb^2)
   END
  KEYWORD_SET(XCT): BEGIN
    FVel = ustar
    RLen = z0
    MOLen = L
    Int = MAKE_ARRAY(NEle, /FLOAT)
    FOR i=0,NEle-1 DO BEGIN
     ZbAtX = Zb[i]
     s = Shape(ZbAtX, z0, L, c)		; Calculate shape parameter
     A = AConst(s, /H94)			; Calculate A parameter
     b = BConst(s, /H94)			; Calculate b parameter
     Uzb = Uzbar(ZbAtX, ustar, L, z0, c)	; Mass-weighted plume advection speed
     Int[i] = QROMO('UbCWIC',z0,zm)
    ENDFOR
;    FPN.Weights = -1.*Centreddifference(Int,INDGEN(N_ELEMENTS(Int)))
    FPN.Weights = -1.*Centreddifference(Int,X)
   END
 ENDCASE
 IF (KEYWORD_SET(Normalise)) THEN FPN.Weights = zm*FPN.Weights/dZbdx
 RETURN, FPN

END