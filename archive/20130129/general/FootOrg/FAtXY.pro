FUNCTION FAtXY, X1, Y1

 COMMON Constants
 COMMON FPNAtXY

; *** First we interpolate zbar from the regularly spaced X series
; *** output by ZbarFnX to the X value input to this function.
; *** NOTE: The arrays X and zbar both increase monotonically, that is
; ***       the first elements contain the smallest values and the
; ***       elements increase in value with increasing index in the
; ***       array.  In contrast, the X1 argument passed in from the
; ***       calling routine, INT_2D in this case, is a vector where
; ***       the element values decrease with increasing index.
 zb = REVERSE(SPLINE(X, zbar, REVERSE(X1)))
; *** Next we get the value of Uzbar at X ...
 Uzb =  (1.0/k)*(ALOG(c*zb/z0)-psim(c*zb,L))
; *** And then the value of SigmaZ at X ...
 SigZ = (GAMMA(SQRT(1.0/s))*GAMMA(SQRT(3.0/s))/GAMMA(2.0/s))*zb
; *** And then the value of SigmaY at X ...
 h = -0.100538*ALOG(X1/1000.0) + 0.562162
 SigY = SigmaTheta*!DTOR*X1*h
; *** Calculate the vertical diffusion term.
 Dz = (k/phih(zm,L))*(1.0/(A*SigZ))*((s*zm^s)/(B*SigZ)^s)*EXP(-(zm/(B*SigZ))^s)
; *** Calculate the horizontal diffusion term.
 Dy = (1.0/(SQRT(2.0*!PI)*SigY))*EXP(-Y1^2/(2.0*SigY^2))
; *** Calculate the source area weight function.
 FPNAtXY = Dy*Dz/Uzb
 RETURN, FPNAtXY

END
