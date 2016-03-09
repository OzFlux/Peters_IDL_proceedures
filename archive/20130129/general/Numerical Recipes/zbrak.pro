PRO ZBrak, func, x1, x2, n, xb1, xb2, nb, nbmax

 xb1 = FLTARR(nbmax)
 xb2 = FLTARR(nbmax)

 nbb = 0
 x = x1
 dx = (x2-x1)/n
 fp = CALL_FUNCTION(func, x)
 FOR i = 1, n DO BEGIN
  x = x + dx
  fc = CALL_FUNCTION(func, x)
  IF (fc*fp LE 0.0) THEN BEGIN
   nbb = nbb + 1
   xb1[nbb-1] = x - dx
   xb2[nbb-1] = x
   IF (nbb EQ nbmax) THEN GOTO, Finish
  ENDIF
  fp = fc
 ENDFOR

Finish:
 nb = nbb

END