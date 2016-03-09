FUNCTION BConst, s, K97=K97, H94=H94

 CASE 1 OF
  KEYWORD_SET(K97):RETURN, SQRT(GAMMA(1./s))/SQRT(GAMMA(3./s))
  KEYWORD_SET(H94):RETURN, GAMMA(1./s)/GAMMA(2./s)
  ELSE:RETURN, GAMMA(1./s)/GAMMA(2./s)
 ENDCASE

END