FUNCTION SWFAtX_Golden, X

 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const

 Zbx = Zbar(ZbAtX, XAtZb, X)
 dZbdx = dZbBydx(L, Zbx, z0, p)
 Uzb = Uzbar(Zbx, Us, L, z0, c)
 SWF = -1.*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zbx))^s)/(Zbx^2*Uzb)
 RETURN, SWF

END