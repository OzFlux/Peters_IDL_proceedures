FUNCTION Golden, X, func, tol, xmin
;
; PURPOSE:
;  Given a function, "func", and given a bracketing triplet of abscissas, X,
;  such that X[1] is between X[0] and X[2] and f(X[1]) is less than both
;  f(X[0]) and f(X[2]), this routine performs a golden search for the
;  minimum, isolating it to a fractional precision of about "tol".  The
;  abscissa of the minimum is returned as "xmin" and the function value
; is returned as "Golden".
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., 394-395
; DATE: ??03/2002
;
 R = 0.61803399
 C = 1.0 - R
 ax = X[0] & bx = X[1] & cx = X[2]
 x0 = ax
 x3 = cx
 CASE 1 OF
  (ABS(cx-bx) GT ABS(bx-ax)): BEGIN
   x1 = bx
   x2 = bx + C*(cx-bx)
   END
  ELSE: BEGIN
   x2 = bx
   x1 = bx - C*(bx-ax)
   END
 ENDCASE
 f1 = CALL_FUNCTION(func, x1)
 f2 = CALL_FUNCTION(func, x2)
 WHILE (ABS(x3-x0) GT tol*(ABS(x1)+ABS(x2))) DO BEGIN
  CASE 1 OF
   (f2 LT f1): BEGIN
    x0 = x1
    x1 = x2
    x2 = R*x1 + C*x3
    f1 = f2
    f2 = CALL_FUNCTION(func, x2)
    END
   ELSE: BEGIN
    x3 = x2
    x2 = x1
    x1 = R*x2 + C*x0
    f2 = f1
    f1 = CALL_FUNCTION(func, x1)
    END
  ENDCASE
 ENDWHILE
 CASE 1 OF
  (f1 LT f2): BEGIN
   Golden = f1
   xmin = x1
   END
  ELSE: BEGIN
   Golden = f2
   xmin = x2
   END
 ENDCASE

 RETURN, Golden

END