FUNCTION PSIFnZ, L, z, z0, p
; *** Function to evaluate Eqn A10 from Horst and Weil (1994).  Eqn
; *** A10 provides an exact solution of the change in mean plume
; *** height with downwind distance.  This is an alternative to the
; *** usual approach of integrating numerically Eqn 8 in HW94.
; *** NOTES:
; ***  1) Equation A10 in Horst and Weil 1994 was incorrect, the
; ***     correct equation was published in a Corrigenda in
; ***     JAOT, 12, April 1995, p 447.
; ***  2) HW94 and HW95 use a different form for the psim function
; ***     than the one used here (see Paulson 1970).

 COMMON Constants

 IF (1./L GE 0.0) THEN BEGIN
  T1 = DOUBLE(z/(k^2*z0))
  T2 = DOUBLE(ALOG(p*z/z0))
  T3 = 1.D
  T4 = DOUBLE(5.D*p*z/L)
  T5 = DOUBLE(0.25+(5.*p*z/(3.*L))+0.5*ALOG(p*z/z0))
  RETURN, T1*(T2-T3+T4*T5)
 ENDIF ELSE BEGIN
  Yp = DOUBLE((1.D - 16.D*p*z/L)^0.25)
  T1 = DOUBLE((1.D/k^2)*2.D*ABS(L)/(16.D*p*z0))
  T2 = DOUBLE(Yp^2)*(ALOG(p*z/z0)-psim(p*z,L))
  T3 = DOUBLE(2.D*ATAN(Yp))
  T4 = DOUBLE(ALOG((Yp+1.D)/(Yp-1.D)))
  T5 = DOUBLE(4.D*Yp)
  RETURN, T1*(T2+T3+T4-T5)
 ENDELSE

END