FUNCTION CWIFExact, zm, z0, L, Us, MZb, NZb, Normalise=Normalise

 COMMON Constants
 COMMON UbCWIC, s, A, b, Zb, Uzb, UsI, z0I, LI
; *** Define various local constants.
 p = 1.55		; PConst(s)										;1.55 at s=1.5
 c = 0.63		; b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
 UsI = Us
 z0I = z0
 LI = L
; *** Clip the value of L to make believe that the aircraft is
; *** in the surface layer.  We will use a very generous definition
; *** of the depth of the surface layer.
 IF (zm/L LT -5.0) THEN L = -zm/5.0
; *** Calculate Zbar using the analytic expression for x(zbar) from
; *** HW94 Eqns A4 and A10.
; *** First, we create a series of Zbar values ranging from z0 to
; *** ten the measurement height, 10*zm, with 200 values.
 ZbAtX = (FINDGEN(NZb)*MZb/(NZb-1)) + z0
 PSIFnZ0 = PSIFnZ(L, z0, z0, p)		;PSIFnZ returns DOUBLE
 XAtZb = z0*FLOAT(PSIFnZ(L, ZbAtX, z0, p) - PSIFnz0)
 ZbAtX = ZbAtX[WHERE(XAtZb GT 0.0)]
 XAtZb = XAtZb[WHERE(XAtZb GT 0.0)]
 dZbdx = dZbBydx(L, ZbAtX, z0, p)
 NEle = N_ELEMENTS(XAtZb)
; *** Define a structure to hold the footprint weights and distances.
 FPN = {Weights:FLTARR(NEle),Distance:FLTARR(NEle),Zb:FLTARR(NEle)}
 FPN.Distance = XAtZb
 FPN.Zb = ZbAtX
; *** Calculate the integral of u(z)*CWIC(x,z)
 Int = MAKE_ARRAY(NEle, /FLOAT)
 FOR i=0,NEle-1 DO BEGIN
  X = XAtZb[i]
  Zb = Zbar(ZbAtX, XAtZb, X)	; Interpolate ZbAtX from XAtZb to X
  s = Shape(Zb, z0, L, c)		; Calculate shape parameter
  A = AConst(s, /H94)			; Calculate A parameter
  b = BConst(s, /H94)			; Calculate b parameter
  Uzb = Uzbar(Zb, Us, L, z0, c)	; Mass-weighted plume advection speed
  Int[i] = QROMO('UbCWIC',z0,zm)
 ENDFOR
; *** Calculate the cross-wind integrated footprint.
 FPN.Weights = -1.*Centreddifference(Int,INDGEN(N_ELEMENTS(Int)))
 IF (KEYWORD_SET(Normalise)) THEN FPN.Weights = zm*FPN.Weights/dZbdx
 RETURN, FPN

END