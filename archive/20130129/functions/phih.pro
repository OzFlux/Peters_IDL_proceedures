FUNCTION phih, z, L

 Sz = SIZE(z)
 NDz = Sz[0]	; Number of dimensions of z
 SL = SIZE(L)
 NDL = SL[0]	; Number of dimensions of L

 CASE 1 OF
  (NDz EQ 0) AND (NDL EQ 0): BEGIN	; Both z and L are scalars
   CASE 1 OF
    (L LT 0.0): result = 1.0/(1.0 - 16.0*z/L)^0.5
    (L GT 0.0): result = (1.0 +  5.0*z/L)
    ELSE: STOP, 'PHIH: L is zero !', L
   ENDCASE
   END
  ELSE: BEGIN				; Either z or L or both are arrays
   IF (NDz GT 1) OR (NDL GT 1) THEN $
    STOP, 'PHIH: Either z or L is a multidimensional array'
   Nz = N_ELEMENTS(z)		; Number of elements in z
   NL = N_ELEMENTS(L)		; Number of elements in L
   print,Nz,NL
   IF (Nz GT 1) AND (NL GT 1) AND (Nz NE NL) THEN $
    STOP, 'PHIH: z and L are unequal sized arrays'
   NEle = MAX([Nz,NL])		; Number of elements in largest input
   tz = z					; Make copies of the input parameters
   tL = L					; so as not to corrupt the originals
   IF (Nz LT NEle) THEN tz = MAKE_ARRAY(NEle,/FLOAT,VALUE=z)
   IF (NL LT NEle) THEN tL = MAKE_ARRAY(NEle,/FLOAT,VALUE=L)
   print,tz[100],tL[100]
   result = MAKE_ARRAY(NEle, /FLOAT, Value=-9999)
   print,result[100]
   Index = WHERE(tL LT 0.0,Count)	; Unstable conditions
   print,Count
   IF (Count NE 0) THEN BEGIN
    ;phih = 1.0/(1.0 - 16.0*tz/tL)^0.5
    ;phih[Index] = 1.0/(1.0 - 16.0*tz[Index]/tL[Index])^0.5
    t1 = tz[Index]/tL[Index]
    t2 = SQRT(1.0 - 16.0*t1)
    val = 1.0/t2
    Index = [2,3,4]
    result = val
    ;print,n_elements(val),n_elements(result)
    print,result[Index],val[Index]
    ;print,result
   END
   print,Index[100],result[100],tz[100],tL[100],t1[100],t2[100],val[100]
   Index = WHERE(tL GT 0.0,Count)	; Stable conditions
   IF Count NE 0 THEN result[Index] = (1.0 +  5.0*tz[Index]/tL[Index])
   END						; End of z or L or both array block
  ENDCASE					; End of scalar or array CASE statement

 RETURN, result

END
