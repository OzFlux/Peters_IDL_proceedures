FUNCTION SWFAtX_Rtbis, X

 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const

 Zb = Zbar(ZbAtX, XAtZb, X)
 dZbdx = dZbBydx(L, Zb, z0, p)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 SWF = dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
 RETURN, SWF-FVal

END