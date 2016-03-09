PRO SrcWgt_A
; PURPOSE:
;  This procedure calculates the dimensions of the upwind surface
;  that contributes 10%, 20% 30% ... 80% and 90% of the flux
;  observed at the measurement height.  The approximate form of
;  the cross-wind integrated footprint from Horst & Weil (1994)
;  is used and the numerical technique for determining the upwind
;  dimensions follows that of Schmid (1994).  Contributions are
;  ignored from upwind distances beyond the point where the cross-
;  wind integrated footprint drops to 0.1% of the maximum value.
;
;  Note that this procedure uses the cross-wind integrated footprint
;  function, CWIF, to determine the upwind dimension of the source
;  area.  This is the approach adopted by Kaharabata et al (1997) and
;  Samuelsson & Tjernstrom (1999) to determine the footprint of
;  aircraft measurements.  The 3D footprint function:
;    f(x,y,zm) = Dy(x,y)*CWIF(x,zm)
;  used to estimate the footprint of tower observations gives similar
;  results for the upwind distances that bound the source area
;  contributing ~80% of the flux.  However, the 3D function reaches
;  its maximum value closer to the measurement location than the CWIF
;  and its value drops more rapidly with increasing upwind distance.
;  I believe that the 3D footprint function should be used to estimate
;  the footprint of both tower-based and aircraft observations for
;  2 reasons:
;   1) the footprint concept is based on the diffusion of passive
;      scalars from elemental surface areas upwind of the
;      measurement point.  This means that the footprint is a
;      property of the air being sampled not the platform doing
;      the sampling
;   2) using the CWIF to estimate the footprint of aircraft
;      observations will give a different answer to the 3D method
;      for towers in the limit of the aircraft ground speed tending
;      to zero.
; INPUTS:
;  No explicit inputs but the measurement height, roughness length
;  and meteorological data need to be specified at the beginning of
;  the procedure code.
; OUTPUTS:
;  No explicit outputs.
;  The procedure generates a plot of the cross-wind integrated footprint
;  function versus upwind distance and a plot of the fractional
;  contribution to the observed flux versus fraction of the maximum
;  value of the cross-wind integrated footprint.
;  The procedure also generates 2 tables that list the upwind dimensions
;  Xp1 (closest to measurement location) and Xp2 (furthest from
;  measurement location) for a range of fractional contributions to
;  the observed flux.
; METHOD:
;  The upwind distances corresponding to a range of Zbar values is
;  calculated using the analytic expressions in Horst and Weil (1994)
;  and Horst and Weil (1995).  The cross-wind integrated footprint
;  function is then evaluated at these upwind distances. If the value
;  at the maximum upwind distance is greater than 0.1% of the function
;  maximum, the range of Zbar is extended until the function value at
;  maximum upwind distance is less than 0.1% of the function maximum.
;  The resulting values of Zbar and upwind distance, ZbAtX and XAtZb
;  respectively, are stored in a common block and subsequent values
;  of Zbar at intermediate values of X are found by interpolation.
;  The maximum function value, FMax, and the location of the maximum,
;  XMax, are then found using a search routine (GOLDEN) since the spacing of
;  XAtZb can be rather coarse (~15m).  The cross-wind integrated
;  footprint function is then integrated over all upwind distances used.
;  The integral is usually lies in the range 1.00+/-0.05.
;
;  The upwind distances (Xp1 and XP2) corresponding to fractions of the
;  function maximum are found using a root finding routine (RTBIS) and
;  the fractional contribution to the flux from the surface area bounded
;  by these is estimated by integrating (QROMO) the function between the
;  limits Xp1 and Xp2.  This produces a table of contributions corresponding
;  to specified fractions of the function maximum.  Fractions
;  of the function maximum corresponding to specified contributions are
;  then obtained by interpolation and the upwind distances corresponding
;  to these fractions are estimated using a root finding procedure.  A
;  final table is then written which gives the fractional contribution
;  to the flux, the function value at this contribution and the upwind
;  distances (Xp1 and Xp2) corresponding to the function values.
; USES:
;  PSIFnZ - calculates X at Zbar
;  dZbBydx - calculates dZbar/dx at X
;  Uzbar  - calculates U(Zbar), the plume advection speed
;  Shape  - calculates the shape parameter s
;  AConst - calculates the parameter A
;  bConst - calculates the parameter b
;  Psim   - stability correction to logarithmic wind speed profile
;  Golden - searches for function minimum and returns minimum value
;           and location
;  CWIF_Neg - function evaluated by Golden, returns the negative
;             of the cross-wind integrated footprint function
;  Rtbis  - searches for a root of a function and returns the
;           location of the root if found
;  CWIF_Root - function evaluted by Rtbis, returns the value of
;              the cross-wind integrated footprint function minus
;              the specified function value
;  QROMO - IDL procedure to integrate 1D function
;  CWIF - function evaluated by QROMO, returns the value of the
;         cross-wind integrated footprint function
 COMMON Constants
 COMMON Colours
 COMMON SWF_Data, zm, z0, L, Us, SigmaTheta, ZbAtX, XAtZb, Ub, Zbx
 COMMON SWF_Const, c, p, FVal, r2PI
; *** Specify the measurement height, roughness length and the
; *** meteorological data.
 zm = 35.0			; Measurement height, m
 z0 = 0.06			; Roughness length, m
 L = -15.			; Monin-Obukhov length, m
 SigmaTheta = 30.0	; Stdev of wind direction, deg (set but not used)
 Us = 1.0			; Friction velocity, m/s
; *** Define various local constants.
 NZb = 500			; Initial number of Zbar values
 MHgt = 20.0		; Initial factor, maximum Zbar=MHgt*zm
 p = 1.55			; PConst(s)										;1.55 at s=1.5
 c = 0.63			; b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
 r2PI = SQRT(2.*!PI)
; *** Clip the value of L to make believe that the aircraft is
; *** in the surface layer.  We will use a very generous definition
; *** of the depth of the surface layer.
 IF (zm/L LT -5.0) THEN L = -zm/5.0
; *** Calculate Zbar using the analytic expression for x(zbar) from
; *** HW94 Eqns A4 and A10.
; *** First, we create a series of Zbar values ranging from z0 to
; *** ten the measurement height, 10*zm, with 200 values.
 n = 0
Start:
 n = n + 1
 ZbAtX = (FINDGEN(NZb)*MHgt*zm/(NZb-1)) + z0
 PSIFnZ0 = PSIFnZ(L, z0, z0, p)		;PSIFnZ returns DOUBLE
 XAtZb = z0*FLOAT(PSIFnZ(L, ZbAtX, z0, p) - PSIFnz0)
 ZbAtX = ZbAtX[WHERE(XAtZb GT 0.0)]
 XAtZb = XAtZb[WHERE(XAtZb GT 0.0)]
 NEle = N_ELEMENTS(XAtZb)
; *** Calculate dZb/dx, the rate of change of Zb with downwind distance.
 dZbdx = dZbBydx(L, ZbAtX, z0, p)
; *** Calculate Uzb, the mean advection speed of the plume.
 Uzb = Uzbar(ZbAtX, Us, L, z0, c)
; *** Calculate the shape parameter, s, and parameters A and b.
 s = Shape(ZbAtX, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
; *** Calculate the mean wind speed at the measurement height, zm.
 Ub = (Us/k)*(ALOG(zm/z0)-Psim(zm,L))
; *** Calculate the cross-wind integrated footprint.
 CWIF = dZbdx*zm*Ub*A*EXP(-(zm/(b*ZbAtX))^s)/(Uzb*ZbAtX^2)
; *** Check the value at the maximum upwind distance, if it
; *** is greater than 0.1% of the function maximum then
; *** extend the range of Zbar and the number of Zbar values
; *** by 25% and recalculate the cross-wind integrated footprint.
 FMax = MAX(CWIF)
 IF (CWIF[NEle-1] GT 0.001*FMax) THEN BEGIN
  IF (n GE 20) THEN STOP,'More than 20 iterations in MHgt'
  MHgt = 1.25*MHgt
  NZb = 1.25*NZb
  GOTO, Start
 ENDIF
; *** Plot the cross wind integrated flux.
 WINDOW,0,TITLE='Cross wind integrated flux'
 PLOT, XAtZb, CWIF
; *** Search for the maximum of the cross-wind integrated footprint function.
 NEle = N_ELEMENTS(XAtZb)									; Number of elements
 Index = WHERE(CWIF EQ FMax)								; Location of maximum contribution
 X = [XAtZb[Index[0]-2],XAtZb[Index[0]],XAtZb[Index[0]+2]]	; First guess at bracketing triplet
; *** The routine used to find the maximum (actually the minimum) of the
; *** footprint function, Golden, has problems when the function values
; *** and tolerance (0.001*FMax in our case) get small (ie FMax~4E-5
; *** and tol~4E-8).  The problem is probably round-off error and
; *** might be cured by re-writing the routine to use double precision.
; *** Rather than do this, we will pass FMax to the function being
; *** minimised (CWIF_Neg) by setting FVal to FMax.  CWIF_Neg
; *** will then use FVal to normalise the footprint function so that
; *** its minimum value is approximately -1.
 FVal = FMax									; Set FVal for normalisation
 FMax = -1.*Golden(X,'CWIF_Neg',0.001,XMax)		; Search for maximum
 FMax = FMax*FVal								; Undo normalisation
 FVal = FMax*0.001								; Integrate to 0.1% of maximum
; *** Integrate the cross wind integrated flux.
 PLim = QROMO('CWIF',XAtZb[0],XAtZb[NEle-1])
 PRINT,'    zm','    z0','           L','        FMax','  XMax','   Zbx','  PLim','  MHgt','   Nzb','     N'
 PRINT,zm,z0,L,FMax,XMax,Zbx,PLim,MHgt,Nzb,N,FORMAT='(2F6.2,2E12.2,F6.1,3F6.2,2I6)'
; *** Now get the fractional contribution to the flux at a range of
; *** source weight function values.
 FLev = [0.001,0.01,0.02,0.04,0.06,0.08,0.1,0.15,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.975,0.99]
 NLev = N_ELEMENTS(FLev)
 Xp1 = FLTARR(NLev)
 Xp2 = FLTARR(NLev)
 Pf = FLTARR(NLev)
 FOR i=0, NLev-1 DO BEGIN
  FVal = FMax*FLev[i]
  Xp1[i] = Rtbis('CWIF_Root',[0.0,XMax],0.01)
  Xp2[i] = Rtbis('CWIF_Root',[XMax,XAtZb[NEle-1]],0.01)
  Pf[i] = QROMO('CWIF',Xp1[i],Xp2[i])
  IF (i EQ 0) THEN PRINT, '    Flev','       Fval','      Pf','     Xp1','     Xp2'
  PRINT, FLev[i],FVal,Pf[i],Xp1[i],Xp2[i], $
   FORMAT='(F8.3,E11.3,F8.3,2F8.1)'
 ENDFOR
; *** Plot the percentage contribution to the flux as a function of
; *** the fraction of Fmax and work out the best fit.
 WINDOW, 1, TITLE='Contribution versus fraction of Fmax'
 PLOT, FLev, Pf, /NODATA, $
  XRANGE=[0,1], YRANGE=[0,1], $
  XTITLE='Fraction of Fmax',YTITLE='Contribution to Flux'
 OPLOT, FLev, Pf, PSYM=1, COLOR=yellow
; *** Interpolate the source weight function values from the
; *** irregularly spaced integrals, Pf, to regularly spaced
; *** integral values.  The interpolated source weight function
; *** values then represent the levels to which the function
; *** must be integrated to give fractional contributions to
; *** the flux of 10%, 20%, 30% etc.
; *** NOTE: I have been unable to find a general function that
; ***       fits these points for the full stability range of
; ***       0 > z/L > -2
 PfInt = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,Pf[0]]
 FFit = INTERPOL(REVERSE(FLev),REVERSE(Pf),PfInt)
 OPLOT, FFit, PfInt, PSYM=1, COLOR=blue
; *** Now calculate the source area dimensions at the function levels
; *** corresponding to the fractional contributions in PfInt.
 NLev = N_ELEMENTS(FFit)
 Xp1f = FLTARR(NLev)
 Xp2f = FLTARR(NLev)
 PfFit = FLTARR(NLev)
 FOR i=0, Nlev-1 DO BEGIN
  FVal = FMax*FFit[i]
  Xp1f[i] = Rtbis('CWIF_Root',[0.0,XMax],0.01)
  Xp2f[i] = Rtbis('CWIF_Root',[XMax,XAtZb[NEle-1]],0.01)
  PfFit[i] = QROMO('CWIF',Xp1f[i],Xp2f[i])
  IF (i EQ 0) THEN BEGIN
   PRINT, '      zm','      z0','           L','        FMax','    XMax'
   PRINT, zm,z0,L,FMax,XMax,FORMAT='(2F8.2,2E12.3,F8.1)'
   PRINT,'%Contrib', '  CWIF Value','     Xp1','     Xp2'
  ENDIF
  PRINT,PfFit[i], Fval,Xp1f[i],Xp2f[i], FORMAT='(F8.3,E12.3,2F8.1)'
 ENDFOR

END