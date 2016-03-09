FUNCTION Uzbar, Zb, ustar, L, z0, c

 COMMON Constants

 CASE 1 OF
  (1./L GT 0.): RETURN, (ustar/k)*(ALOG(c*Zb/z0)+4.7*Zb/L)
  (1./L LE 0.): RETURN, (ustar/k)*(ALOG(c*Zb/z0)-Psim(c*Zb,L))
 ENDCASE

END