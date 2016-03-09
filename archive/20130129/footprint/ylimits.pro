FUNCTION YLimits, X
;
; PURPOSE:
;  This function returns the Y coordinates of the footprint function
;  isopleth FVal (FVal is passed in the common block SWF_Const) at
;  the specified X coordinate (X is passed as an argument to this
;  function).  This routine is used by INT_2D to integrate the
;  footprint function over a specified range of X coordinates.
;  Note that the isopleth is symmetrical about the X axis so that
;  a single X value corresponds to a positive and a negative Y
;  value.
;
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)
 s = Shape(Zb, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 dZbdx = dZbBydx(L, Zb, z0, p)
 SigY = SigmaY(SigmaTheta, X)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 Num = DOUBLE(SQRT(2*!PI)*SigY*Zb^2*FVal*Uzb)
 Den = DOUBLE(dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s))
 Arg1 = Num/Den
 IF Arg1 LE 0.0 THEN STOP,'YLimts: Arg1 is negative or zero'
 Arg2 = -2.D*SigY^2*ALOG(Arg1)
 IF Arg2 LT 0.0D THEN Arg2 = 0.0D
 YPos =  SQRT(Arg2)
 YNeg = -SQRT(Arg2)
 RETURN,[YNeg,YPos]
END