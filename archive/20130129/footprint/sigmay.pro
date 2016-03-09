FUNCTION SigmaY, SigmaTheta, X
; PURPOSE:
;  Function to calculate the horizontal plume spread from
;  the standard deviation of wind direction and the
;  downwind distance.
; INPUT:
;  SigmaTheta - standard deviation of wind direction, deg
;  X          - downwind distance, m
COMMON SWF_Const
CASE 1 OF
 (SigYMethod EQ 'K97'): SigY = SigmaTheta*!DTOR*X*(-0.100538*ALOG(X/1000.0)+0.562162)
 (SigYMethod EQ 'P76'): SigY = SigmaTheta*!DTOR*X/(1.+0.0208*SQRT(X))
 (SigYMethod EQ 'S94'): SigY = SigmaTheta*!DTOR*X
 ELSE: STOP,'SigmaY: Unrecognised SigYMethod'
ENDCASE
RETURN, SigY
END