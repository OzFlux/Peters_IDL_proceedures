FUNCTION DY, SigY, Y
; PURPOSE
;  Function to return the cross-wind concentration distribution.
 Dy = EXP(-0.5*(Y/SigY)^2)/(SQRT(2.*!PI)*SigY)
 RETURN, Dy

END