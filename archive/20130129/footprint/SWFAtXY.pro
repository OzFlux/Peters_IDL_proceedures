FUNCTION FPNAtX&Y_Int, X, Y
;
; PURPOSE:
;

 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const

 Zb = Zbar(ZbAtX, XAtZb, X)
 dZbdx = dZbBydx(L, Zb, z0, p)
 SigY = SigmaY(SigmaTheta, X)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 SWF = Dy(SigY, Y)*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
 RETURN, SWF

END