PRO SrcWgt_A

 COMMON Constants
 COMMON Colours
 COMMON FPN_Parameters, zm, z0, L, SigWD, ustar, s, c, p, A, b, SigY, Method
 COMMON YLimits, FLim

 MaxX = 5000.0
 zm = 49.0
 z0 = 0.06
 L = -15.0
 ustar = 0.21
 Method = 'H'		; (H/K) Horst&Weil or Kaharabata
 IF (Method EQ 'H') THEN BEGIN
  p = 1.55	;PConst(s)										;1.55 at s=1.5
  c = 0.63	;b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
  XMax = ZbarFnX(MaxX,/ANALYTIC)
  X = FINDGEN(FIX(XMax)) + 1.0
  Zb = Zbar(X)
  s = Shape(Zb, z0, L, c)
  A = AConst(s)												;0.73 at s=1.5
  b = BConst(s)												;1.52 at s=1.5
 ENDIF ELSE BEGIN
  s = 1.4
  A = AConst(s)												;0.73 at s=1.5
  b = BConst(s)												;1.52 at s=1.5
  p = PConst(s)												;1.55 at s=1.5
  c = 0.562
  XMax = ZbarFnX(MaxX,/ANALYTIC)
  X = FINDGEN(FIX(XMax)) + 1.0
  Zb = Zbar(X)
 ENDELSE

 Uzb = Uzbar(Zb)
 dD = dD(Zb)
 Dz = Dz(Zb)

 FAtY0 = dD*Dz/Uzb
 FMax = MAX(FAtY0)
 XMax = X[WHERE(FAtY0 EQ FMax)]
 Zbx = Zb[WHERE(FAtY0 EQ FMax)]
; *** Set the source weight function limit to 0.1% of the
; *** maximum and truncate the X coordinate at this limit.
 FLim = FMax*0.001
 Index = WHERE(FAtY0 GE FLim,Count)
 IF Count NE 0 THEN BEGIN
  LI = MIN(Index)
  RI = MAX(Index)
  Xp1 = X[LI]
  Xp2 = X[RI]
  X = X[LI:RI]
  FAtY0 = FAtY0[LI:RI]
  Zb = Zb[LI:RI]
  Uzb = Uzb[LI:RI]
  dD = dD[LI:RI]
  Dz = Dz[LI:RI]
  IF (Method EQ 'H') THEN A = A[LI:RI]
  IF (Method EQ 'H') THEN b = b[LI:RI]
 ENDIF
; *** Plot the cross wind integrated flux.
 WINDOW,0,TITLE='Cross wind integrated flux'
 PLOT, X, FAtY0
 Pause
; *** Integrate the cross wind integrated flux.
 PLim = QROMO('SWFAtX',Xp1,Xp2)
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
  Index = WHERE(FAtY0 GE FVal,Count)
  LI = MIN(Index)
  RI = MAX(Index)
  Xp1[i] = X[LI]
  Xp2[i] = X[RI]
  Pf[i] = QROMO('SWFAtX',Xp1[i],Xp2[i])/PLim
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
  Index = WHERE(FAtY0 GE FVal,Count)
  LI = MIN(Index)
  RI = MAX(Index)
  Xp1f[i] = X[LI]
  Xp2f[i] = X[RI]
  PfFit[i] = QROMO('SWFAtX',Xp1f[i],Xp2f[i])/PLim
  IF (i EQ 0) THEN BEGIN
   PRINT, '      zm','       L','      z0','       FMax','    XMax'
   PRINT, zm,L,z0,FMax,XMax,FORMAT='(3F8.2,E11.3,F8.1)'
   PRINT, '       Fval','   PfFit','     Xp1','     Xp2'
  ENDIF
  PRINT, Fval,PfFit[i],Xp1f[i],Xp2f[i], FORMAT='(E11.3,F8.3,2F8.1)'
 ENDFOR

END