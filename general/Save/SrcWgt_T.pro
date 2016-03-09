PRO SrcWgt_T
;
; *** Calculate the source area weight function for ground based observations.

 COMMON Constants
 COMMON Colours
 COMMON SWF_Data, zm, z0, L, Us, SigmaTheta, ZbAtX, XAtZb, Ub, Zbx
 COMMON SWF_Const, s, c, p, A, b, FVal
 COMMON YLimits, FLim

 NZb = 500
 MHgt = 20.0
 zm = 4.5
 z0 = 0.06
 L = -100.0
 SigmaTheta = 15.0
 Us = 1.0

; *** Define various local constants.
 p = 1.55		; PConst(s)										;1.55 at s=1.5
 c = 0.63		; b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
 s = 1.5		; Shape(Zb, z0, L, c)
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
; *** Calculate the constants A and b.
 A = AConst(s, /H94)
 b = BConst(s, /H94)
; *** Calculate the mean wind speed at the measurement height, zm.
 Ub = (Us/k)*(ALOG(zm/z0)-Psim(zm,L))
; *** Calculate the cross-wind integrated footprint.
 FPN = dZbdx*zm*Ub*A*EXP(-(zm/(b*ZbAtX))^s)/(Uzb*ZbAtX^2)
; *** Calculate the footprint function for Y=0.0
 SigY = SigmaY(SigmaTheta, XAtZb)
 FPNAtY0 = FPN/(r2PI*SigY)
; *** Get the maximum value of the footprint function, the upwind
; *** location of the maximum and set the limit to which the function
; *** will be integrated to 0.1% of the maximum.
 FMax = MAX(FPNAtY0)
 Tmp = XAtZb[WHERE(FPNAtY0 EQ FMax)]
 XMax = Tmp[0]
 Tmp  = ZbAtX[WHERE(FPNAtY0 EQ FMax)]
 Zbx  = Tmp[0]
 FLim = FMax*0.001
; *** Need code here to check that FLim is greater than the last
; *** value in FPNAtY0.
; PRINT, FLim, FPNAtY0[NEle-1]
; *** Select the data points that lie within the limits.
 Index = WHERE(FPNAtY0 GE FLim,Count)
 IF Count NE 0 THEN BEGIN
  LI = MIN(Index)
  RI = MAX(Index)
  ZbAtX = ZbAtX[LI:RI]
  XAtZb = XAtZb[LI:RI]
  FPNAtY0 = FPNAtY0[LI:RI]
  SigY = SigY[LI:RI]
  Uzb = Uzb[LI:RI]
  dZbdx = dZbdx[LI:RI]
 ENDIF
 Xp1 = MIN(XAtZb)
 Xp2 = MAX(XAtZb)
; PRINT, Xp1, Xp2
; *** Get the Y coordinates of the 0.1% isopleth.
 Num = r2PI*SigY*ZbAtX^2*FLim*Uzb
 Den = dZbdx*zm*Ub*A*EXP(-(zm/(b*ZbAtX))^s)
 YLim = SQRT(-2*SigY^2*ALOG(Num/Den))
; *** Plot the 0.1% isopleth.
 WINDOW,0,TITLE='0.001*FMax isopleth'
 PLOT,[XAtZb,REVERSE(XAtZb)],[YLim,-REVERSE(YLim)]
; *** Plot the footprint function.
 Ypm = FIX(MAX(YLim))
 YAtZb = FINDGEN(2*Ypm+1) - Ypm
 NEleX = N_ELEMENTS(XAtZb)
 NEleY = N_ELEMENTS(YAtZb)
 SWF = FLTARR(NEleX,NEleY)
 FOR i=0,NEleY-1 DO SWF[*,i] = Dy(SigY, YAtZb[i])*dZbdx*zm*Ub*A*EXP(-(zm/(b*ZbAtX))^s)/(Uzb*ZbAtX^2)
 WINDOW, 1, TITLE='Source area weight function'
 SURFACE, SWF, XAtZb, YAtZb, /NODATA, /SAVE, $
  XTITLE='Downwind Distance (m)', YTITLE='Crosswind Distance (m)', $
  ZTITLE='SW Function'
 CONTOUR, SWF, XAtZb, YAtZb, /NOERASE, /T3D, NLEVELS=30
 CONTOUR, SWF, XAtZb, YAtZb, /NOERASE, /T3D, LEVELS=[FLim]
; *** Integrate the source weight function using bivariate numerical
; *** integration with the Y integration limits expressed as a
; *** function of downwind distance.
;
; *** Need a better method of avoiding negative arguments in YLimits
; *** than simply restricting the values of Xp1 and Xp2.
; PLim = INT_2D('SWFAtXY',[Xp1+1.0,Xp2-1.0],'YLimits',96,/DOUBLE)
 PLim = INT_2D('SWFAtXY',[Xp1,Xp2],'YLimits',96,/DOUBLE)
 PRINT,'    zm','    z0','           L','        FMax','  XMax','   Zbx','  PLim'
 PRINT,zm,z0,L,FMax,XMax,Zbx,PLim,FORMAT='(2F6.2,E12.2,E12.2,I6,2F6.2)'
; *** Now get the fractional contribution to the flux at a range of
; *** source weight function values.
 FLev = [0.001,0.01,0.02,0.04,0.06,0.08,0.1,0.15,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.975,0.99]
 NLev = N_ELEMENTS(FLev)
 Xp1 = FLTARR(NLev)
 Xp2 = FLTARR(NLev)
 Pf = FLTARR(NLev)
 FOR i=0, NLev-1 DO BEGIN
  FVal = FMax*FLev[i]
  Index = WHERE(FPNAtY0 GE FVal,Count)
  LI = MIN(Index)
  RI = MAX(Index)
  Xp1[i] = XAtZb[LI]
  Xp2[i] = XAtZb[RI]
  Pf[i] = INT_2D('SWFAtXY',[Xp1[i],Xp2[i]],'YLimits',96,/DOUBLE)
  IF (i EQ 0) THEN PRINT, '    Flev','       Fval','      Pf','     Xp1','     Xp2'
  PRINT, FLev[i],FVal,Pf[i],Xp1[i],Xp2[i], $
   FORMAT='(F8.3,E11.3,F8.3,2F8.1)'
 ENDFOR
; *** Plot the percentage contribution to the flux as a function of
; *** the fraction of Fmax and work out the best fit.
 WINDOW, 2, TITLE='Contribution versus fraction of Fmax'
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
 Ar = FLTARR(NLev)
 Ypm = FLTARR(NLev)
 FOR i=0, Nlev-1 DO BEGIN
  FVal = FMax*FFit[i]
  Index = WHERE(FPNAtY0 GE FVal,Count)
  LI = MIN(Index)
  RI = MAX(Index)
  Xp1f[i] = XAtZb[LI]
  Xp2f[i] = XAtZb[RI]
  PfFit[i] = INT_2D('SWFAtXY',[Xp1f[i],Xp2f[i]],'YLimits',96,/DOUBLE)
  Xf = XAtZb[LI:RI]
  Num = r2PI*SigY[LI:RI]*ZbAtX[LI:RI]^2*FVal*Uzb[LI:RI]
  Den = dZbdx[LI:RI]*zm*Ub*A*EXP(-(zm/(b*ZbAtX[LI:RI]))^s)
  Yf = SQRT(-2*SigY[LI:RI]^2*ALOG(Num/Den))
  IF (i EQ 0) THEN BEGIN
   WINDOW, 3, TITLE='Isopleths at 10%, 20% etc'
   PLOT, [XAtZb,REVERSE(XAtZb)], [YLim,-REVERSE(YLim)], /NODATA
  ENDIF
  OPLOT, [Xf,REVERSE(Xf)], [Yf,-REVERSE(Yf)], COLOR=yellow
  Ar[i] = POLY_AREA([Xf,REVERSE(Xf)], [Yf,-REVERSE(Yf)])
  Ypm[i] = MAX(Yf)
  IF (i EQ 0) THEN BEGIN
   PRINT, '      zm','       L','      z0','   SigWD','       FMax','    XMax'
   PRINT, zm,L,z0,SigmaTheta,FMax,XMax,FORMAT='(4F8.2,E11.3,F8.1)'
   PRINT, '       Fval','   PfFit','     Xp1','     Xp2','     Ypm','      Ar'
  ENDIF
  PRINT, Fval,PfFit[i],Xp1f[i],Xp2f[i],Ypm[i],Ar[i], $
   FORMAT='(E11.3,F8.3,3F8.1,I8)'
 ENDFOR

END