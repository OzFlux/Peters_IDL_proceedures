FUNCTION ZbFnX, x, L, z0

 MaxX = MAX(x)

; *** Exact integral of Eqn 8 from HW94.  This returns the downwind
; *** distance, x, for a range of mean plume heights.
 NEle = 0
Start:
 NEle = NEle + 100
 z = FINDGEN(NEle)+2
 XAtZbar = PHFnZ(z, z0, L) - PHFnZ(z0, z0, L)
 XMax = MAX(XAtZbar)
 IF XMax LT MaxX THEN GOTO, Start
 XMin = MIN(XAtZbar)

 x = x[WHERE(x GE XMin)]
 NEle = N_ELEMENTS(x)
 IF ((NEle MOD 2) EQ 0) THEN x = x[0:NEle-2]
 zbar = SPLINE(XAtZbar, z, x)
 RETURN, zbar

END