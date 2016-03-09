FUNCTION MeanU, ustar, L, z, z0

 COMMON Constants
 RETURN, (ustar/k)*(ALOG(z/z0)-psim(z,L))

END