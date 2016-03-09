FUNCTION GSTrkFromUV, U, V

 GSTrk = MAKE_ARRAY(2, N_ELEMENTS(U), /FLOAT, VALUE=-9999.0)

 Ind = WHERE(U NE -9999. AND V NE -9999., NInd)
 IF (NInd NE 0) THEN GSTrk[0,Ind] = SQRT(U[Ind]*U[Ind] + V[Ind]*V[Ind])

 Ind = WHERE(U GE 0.0 AND V GE 0.0 AND GSTrk[0,Ind] NE 0.0, NInd)
 IF (NInd NE 0) THEN GSTrk[1,Ind] = 90. - ACOS(U[Ind]/GSTrk[0,Ind])*!RADEG
 Ind = WHERE(U GE 0.0 AND V LT 0.0 AND V NE -9999., NInd)
 IF (NInd NE 0) THEN GSTrk[1,Ind] = 90. + ACOS(U[Ind]/GSTrk[0,Ind])*!RADEG
 Ind = WHERE(U LT 0.0 AND U NE -9999. AND V GE 0.0, NInd)
 IF (NInd NE 0) THEN GSTrk[1,Ind] = 450. - ACOS(U[Ind]/GSTrk[0,Ind])*!RADEG
 Ind = WHERE(U LT 0.0 AND U NE -9999. AND V LT 0.0 AND V NE -9999., NInd)
 IF (NInd NE 0) THEN GSTrk[1,Ind] = 90. + ACOS(U[Ind]/GSTrk[0,Ind])*!RADEG

 RETURN, GSTrk

END