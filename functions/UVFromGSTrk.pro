FUNCTION UVFromGSTrk, GS, Trk

 UV = MAKE_ARRAY(2, N_ELEMENTS(GS), /FLOAT, VALUE=-9999.)

 Ind = WHERE(GS EQ 0.0, NInd)
 IF (NInd NE 0) THEN UV[0,Ind] = 0.0
 IF (NInd NE 0) THEN UV[1,Ind] = 0.0

 Ind = WHERE(GS GT 0.0 AND Trk GE 0.0 AND Trk LE 360.0, NInd)
 IF (NInd NE 0) THEN UV[0,Ind] = GS[Ind]*SIN(Trk[Ind]*!DTOR)
 IF (NInd NE 0) THEN UV[1,Ind] = GS[Ind]*COS(Trk[Ind]*!DTOR)

 RETURN, UV

END