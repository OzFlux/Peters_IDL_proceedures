FUNCTION RTBis, Func, xbrac, Acc
;
; PURPOSE:
;  Using bisection, find the root of a function, "Func", known to lie
;  between xbrac[0] and xbrac[1].  The root, returned as RTBIS, will be
;  refined until its accuracy is +/-Acc.
; INPUT:
;  Func  - scalar string containing the name of the function
;  xbrac - 1D array containing 2 elements that are abscissa values
;          bracketing the root
;  Acc   - accuracy, in +/- abscissa units, to which the root will
;          be refined
; OUTPUT:
;  RTBis - the function returns the root to the within the specified
;          accuracy
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., 347
;
 x1 = xbrac[0] & x2 = xbrac[1]
 fmid = CALL_FUNCTION(Func, x2)
 f = CALL_FUNCTION(Func, x1)
 IF (f*fmid GE 0.0) THEN BEGIN
  PRINT,x1,x2
  PRINT,f,fmid
  STOP, 'RTBIS: Bracket values do not enclose a root'
 ENDIF
 IF (f LT 0.0) THEN BEGIN
  RTBis = x1
  dx = x2 - x1
 ENDIF ELSE BEGIN
  RTBis = x2
  dx = x1 - x2
 ENDELSE
 FOR i = 1, 40 DO BEGIN
  dx = dx*0.5
  xmid = RTBis + dx
  fmid = CALL_FUNCTION(Func, xmid)
  IF (fmid LE 0.0) THEN RTBis = xmid
;  print,i,dx,Acc,fmid,RTBis,xmid
  IF (ABS(dx) LT Acc OR fmid EQ 0.0) THEN RETURN, RTBis
 ENDFOR
 STOP, 'RTBis: Root not found after 40 bisections'
END