FUNCTION ZbarFnX, MaxX, Analytic=Analytic

 COMMON FPN_Parameters
 COMMON FPN_Zbar, XAtZb, ZbAtX

 MaxZ = 2000.
 ZInt = 0.1
 XInt = 1.0
 NEle = MaxX/XInt
 ZbAtX = MAKE_ARRAY(NEle, /FLOAT, VALUE=-9999.0)
 XAtZb = MAKE_ARRAY(NEle, /FLOAT, VALUE=-9999.0)

 IF KEYWORD_SET(Analytic) THEN BEGIN
; *** Use analytic expression for x(zbar) from HW94 Eqns A4 and A10.
  PRINT, 'ZbarFnZ: Using analytical expression for x=f(zbar)'
  i = 0
  ZbAtX[i] = z0
  XAtZb[i] = 0.0
  PSIFnZ0 = PSIFnZ(z0)		;PSIFnZ returns DOUBLE
  WHILE i LT NEle-1 AND ZbAtX[i] LE MaxZ DO BEGIN
   i = i + 1
   ZbAtX[i] = ZbAtX[i-1] + ZInt
   XAtZb[i] = z0*FLOAT(PSIFnZ(ZbAtX[i]) - PSIFnZ0)	;PSIFnZ returns DOUBLE
  ENDWHILE
  Index = WHERE(ZbAtX NE -9999.0,Count)
  IF Count NE 0 THEN BEGIN
   ZbAtX = ZbAtX[Index]
   XAtZb = XAtZb[Index]
  ENDIF
 ENDIF ELSE BEGIN
; *** Integrate HW94 Eqn 8 numerically to get zbar(x)
  PRINT, 'ZbarFnX: Using numerical integration of dzbar/dx'
  z = MAKE_ARRAY(1,/FLOAT,VALUE=z0)
  x = 0.0
  dydx = dzbdx(x,z)
  i = 0
  ZbAtX[i] = z0
  XAtZb[i] = 0.0
  WHILE i LT NEle-1 AND ZbAtX[i] LE MaxZ DO BEGIN
   i = i + 1
   z = rk4(z,dydx,x,XInt,'dzbdx',/DOUBLE)
   x = x + XInt
   dydx = dzbdx(x,z)
   ZbAtX[i] = z[0]
   XAtZb[i] = x
  ENDWHILE
  Index = WHERE(ZbAtX NE -9999.0,Count)
  IF Count NE 0 THEN BEGIN
   ZbAtX = ZbAtX[Index]
   XAtZb = XAtZb[Index]
  ENDIF
 ENDELSE

 RETURN, MAX(XAtZb)

END