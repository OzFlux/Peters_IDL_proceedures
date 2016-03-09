FUNCTION SWFRoot, Y
 COMMON SWFRoot
 DyRoot = EXP(-0.5*(Y/SigYRoot)^2)/(SQRT(2.*!PI)*SigYRoot)
 RETURN, (dDRoot*DzRoot*DyRoot/UzbRoot)-FRoot
END
