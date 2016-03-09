FUNCTION SigmaY, SigmaTheta, X
; PURPOSE:
;  Function to calculate the horizontal plume spread from
;  the standard deviation of wind direction and the
;  downwind distance.
; INPUT:
;  SigmaTheta - standard deviation of wind direction, deg
;  X          - downwind distance, m
  SigY = SigmaTheta*!DTOR*X/(1.+0.0208*SQRT(X))
  RETURN, SigY
END