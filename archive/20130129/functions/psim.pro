FUNCTION psim, z, L

 Sz = SIZE(z)
 NDz = Sz[0]	; Number of dimensions of z
 SL = SIZE(L)
 NDL = SL[0]	; Number of dimensions of L

 CASE 1 OF
  (NDz EQ 0) AND (NDL EQ 0): BEGIN	; Both z and L are scalars
   CASE 1 OF
    (L LT 0.0): BEGIN
     x = (1.0 - 16.0*z/L)^0.25
     psim = 2.0*ALOG((x+1.0)/2.0)+ALOG((x^2+1)/2.0)-2.0*ATAN(x)+!PI/2.0
     END
    (L GT 0.0): psim = -5.0*z/L
    ELSE: STOP, 'PSIM: L is zero !', L
   ENDCASE
   END
  ELSE: BEGIN				; Either z or L or both are arrays
   IF (NDz GT 1) OR (NDL GT 1) THEN $
    STOP, 'PSIM: Either z or L is a multidimensional array'
   Nz = N_ELEMENTS(z)		; Number of elements in z
   NL = N_ELEMENTS(L)		; Number of elements in L
   IF (Nz GT 1) AND (NL GT 1) AND (Nz NE NL) THEN $
    STOP, 'PSIM: z and L are unequal sized arrays'
   NEle = MAX([Nz,NL])		; Number of elements in largest input
   tz = z					; Make copies of the input parameters
   tL = L					; so as not to corrupt the originals
   IF (Nz LT NEle) THEN tz = MAKE_ARRAY(NEle,/FLOAT,VALUE=z)
   IF (NL LT NEle) THEN tL = MAKE_ARRAY(NEle,/FLOAT,VALUE=L)
   psim = MAKE_ARRAY(NEle, /FLOAT, Value=-9999)
   x = MAKE_ARRAY(NEle, /FLOAT, Value=-9999)
   ;Index = WHERE(tL LT 0.0,Count)	; Unstable conditions
   ;IF (Count NE 0) THEN BEGIN
    ;x[Index] = (1.0 - 16.0*tz[Index]/tL[Index])^0.25
    ;psim[Index] = 2.0*alog((x[Index]+1.0)/2.0)+alog((x[Index]^2+1)/2.0)-2.0*atan(x[Index])+!PI/2.0
    x = (1.0 - 16.0*tz/tL)^0.25
    psim = 2.0*alog((x+1.0)/2.0)+alog((x^2+1)/2.0)-2.0*atan(x)+!PI/2.0
   ;ENDIF
   ;Index = WHERE(tL GT 0.0,Count)	; Stable conditions
   ;IF Count NE 0 THEN BEGIN
    ;psim[Index] = -5.0*tz[Index]/tL[Index]
    psim = -5.0*tz/tL
   ;ENDIF
   END
  ENDCASE					; End of scalar or array CASE statement

 RETURN, psim

END