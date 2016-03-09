FUNCTION PHFnZ, z, z0, L

; Function to evaluate Eqn A10 from Horst and Weil (1994).  Eqn
; A10 provides an exact solution of the change in mean plume
; height with downwind distance.  This is an alternative to the
; usual approach of integrating numerically Eqn 8 in HW94.

 k = 0.4
 p = 1.5407

 Yp = (1.0 - 16.0*p*z/L)^0.25

 T1 = (1/k^2)*2.0*ABS(L)/(16.0*p*z0)
 T2 = 2.0*(Yp^2 + 1.0)*ATAN(Yp)
 T3 = (Yp^2 - 1.0)*ALOG((Yp + 1.0)/(Yp - 1.0))
 T4 = 4.0*Yp
 T5 = (Yp^2)*(3.0*ALOG(2.0) - !PI/2.0 - ALOG(16.0*p*z0/ABS(L)))
 PHFnZ = T1*(T2 - T3 - T4 + T5)
 RETURN, PHFnZ

END