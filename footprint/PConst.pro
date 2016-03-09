FUNCTION PConst, s
 RETURN, (s*(GAMMA(2./s)/GAMMA(1./s))^s)^(1./(1.-s))
END