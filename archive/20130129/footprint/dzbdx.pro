FUNCTION dzbdx, x, zb

 COMMON Constants
 COMMON FPN_Parameters

 pzb = p*zb[0]
 dzbdx = k^2/((ALOG(pzb/z0)-psim(pzb,L))*phih(pzb,L))
 RETURN, dzbdx

END