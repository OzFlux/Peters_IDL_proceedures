FUNCTION FAtX, y

 COMMON FPNAtX, fFval, fSigY, fDz, fUzb

 fDy = (1.0/(SQRT(2.0*!PI)*fSigY))*EXP(-y^2/(2.0*fSigY^2))
 RETURN, fDy*fDz/fUzb - fFval

END