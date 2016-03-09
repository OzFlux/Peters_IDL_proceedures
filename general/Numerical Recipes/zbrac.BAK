PRO ZBrac, func, xbrac, Success
;
; PURPOSE:
;  Given a function, func, and an initial guessed range xbrac[0] to xbrac[1],
;  the routine expands the range geometrically until a root is bracketed
;  by the returned values xbrac[0] and xbrac[1] (in which case Success returns
;  as true (=1)) or until the range becomes unacceptably large (in which case
;  Success returns as false (=0)).
; INPUT:
;  func    - scalar string containing the name of the function
;  xbrac   - 1D array of 2 elements containing the initial guess for
;            the points bracketing a root
; OUTPUT:
;  xbrac   - 1D array of 2 elements containing the initial guess on input
;            and the actual bracketing values on output
;  Success - integer, a value of 1 indicates the routine was able to
;            find 2 values that bracket a root and a value of 0
;            indicates the routine was not able to find a bracketing
;            pair
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., p345
;
 Factor = 1.6
 NTry = 50
 x1 = xbrac[0] & x2 = xbrac[1]
 IF (x1 EQ x2) THEN STOP, 'ZBrac: x1 equals x2'
 f1 = CALL_FUNCTION(func, x1)
 f2 = CALL_FUNCTION(func, x2)
 Success = 1
 FOR j = 1, NTry DO BEGIN
  IF (f1*f2 LT 0.) THEN GOTO, Finish
  IF (ABS(f1) LT ABS(f2)) THEN BEGIN
   x1 = x1 + Factor*(x1-x2)
   f1 = CALL_FUNCTION(func, x1)
  ENDIF ELSE BEGIN
   x2 = x2 + Factor*(x2-x1)
   f2 = CALL_FUNCTION(func, x2)
  ENDELSE
 ENDFOR
 Success = 0
Finish:
 xbrac[0] = x1 & xbrac[1] = x2
END