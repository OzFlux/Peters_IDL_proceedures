PRO MnBrak, X, FAtX, func
;
; PURPOSE:
;  Given a function, "func", and given distinct intial points, X[0], X[1]
;  and X[2], this routine searches in the downhill direction (defined by
;  the function evaluated at the initial points) and returns new points
;  X[0], X[1] and X[2] that bracket a minimum of the function.  Also
;  returned are the function values at the three points, FAtX[0],
;  FAtX[1] and FAtX[2].
; INPUT:
;  X    - 1D array of 3 elements containing initial points that are
;         expected to bracket a minimum
;  func - string scalar containing the name of the function for
;         which we wish to bracket a minimum
; OUTPUT:
;  X    - 1D array of 3 elements containing the points that bracket
;         a minimum of the function
;  FAtX - 1D array of 3 elements containing the function value at
;         X[0], X[1] and X[2]
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., 393-394

 Gold = 1.618034
 GLimit = 100.0
 Tiny = 1.0E-20

 ax = X[0] & bx = X[1] & cx = X[2]
 fa = CALL_FUNCTION(func, ax)
 fb = CALL_FUNCTION(func, bx)
 IF (fb GT fa) THEN BEGIN
  dum = ax
  ax = bx
  bx = dum
  dum = fb
  fb = fa
  fa = dum
 ENDIF
 cx = bx + Gold*(bx - ax)
 fc = CALL_FUNCTION(func, cx)
 WHILE (fb GT fc) DO BEGIN
  r = (bx-ax)*(fb-fc)
  q = (bx-cx)*(fb-fa)
  sign = ABS(q-r)/(q-r)
  u = bx-((bx-cx)*q-(bx-ax)*r)/(2.*sign*MAX([ABS(q-r),Tiny]))
  ulim = bx + GLimit*(cx-bx)
  CASE 1 OF
   ((bx-u)*(u-cx) GT 0.): BEGIN
     fu = CALL_FUNCTION(func, u)
     IF (fu LT fc) THEN BEGIN
      ax = bx
      fa = fb
      bx = u
      fb = fu
      GOTO, Finish
     ENDIF
     IF (fu GT fb) THEN BEGIN
      cx = u
      fc = fu
      GOTO, Finish
     ENDIF
     u = cx + Gold*(cx-bx)
     fu = CALL_FUNCTION(func, u)
    END
   ((cx-u)*(u-ulim) GT 0.): BEGIN
     fu = CALL_FUNCTION(func, u)
     IF (fu LT fc) THEN BEGIN
      bx = cx
      cx = u
      u = cx + Gold*(cx-bx)
      fb = fc
      fc = fu
      fu = CALL_FUNCTION(func, u)
     ENDIF
    END
   ((u-ulim)*(ulim-cx) GE 0.): BEGIN
     u = ulim
     fu = CALL_FUNCTION(func, u)
    END
   ELSE: BEGIN
     u = cx + Gold*(cx-bx)
     fu = CALL_FUNCTION(func, u)
    END
  ENDCASE
  ax = bx
  bx = cx
  cx = u
  fa = fb
  fb = fc
  fc = fu
 ENDWHILE

Finish:
 X[0] = ax & X[1] = bx & X[2] = cx
 FAtX[0] = fa & FAtX[1] = fb & FAtX[2] = fc
END