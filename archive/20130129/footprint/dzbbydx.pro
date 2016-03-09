FUNCTION dzbbydx, L, zb, z0, p

 COMMON Constants

 pzb = p*zb
 a = phih(pzb,L)
 RETURN, k^2/((ALOG(pzb/z0)-psim(pzb,L))*a)
; RETURN, k^2/((ALOG(pzb/z0)-psim(pzb,L))*phih(pzb,L))

END