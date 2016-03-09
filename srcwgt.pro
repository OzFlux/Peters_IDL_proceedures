PRO SrcWgt
; PURPOSE:
;  This procedure calculates the area of the upwind surface
;  that contributes 10%, 20% 30% ... 80% and 90% of the flux
;  observed at the measurement height.  The approximate form of
;  the cross-wind integrated footprint from Horst & Weil (1994)
;  is used and the numerical technique for determining the upwind
;  dimensions follows that of Schmid (1994).  Contributions are
;  ignored from upwind distances beyond the point where the cross-
;  wind integrated footprint drops to 0.1% of the maximum value.
; INPUTS:
;  No explicit inputs but the measurement height, roughness length
;  and meteorological data need to be specified at the beginning of
;  the procedure code.
; OUTPUTS:
;  No explicit outputs.
;  The procedure generates 4 plots.
;  The first is an XY plot of the 0.1% isopleth of the 3D footprint
;  function.
;  The second is a 3D plot of the footprint function with 30
;  levels, the lowest level is at 0.1% of the function maximum and
;  represents the limit over which the function is integrated to
;  estimate the total integral (should be 1.0).
;  The third is an XY plot showing the fractional contribution to
;  the flux versus the fraction of the function maximum.
;  The fourth is an XY plot showing the footprint isopleths at
;  10%, 20%, 30% ... 80%, 90% and 0.1%*FMax.
;  The procedure also writes two tables to the output log window.
;  The first table gives the fraction of FMax and the corresponding
;  upwind and across-wind dimensions of the footprint.  The second
;  table gives the fractional contribution to the flux and the
;  corresponding fraction of FMax, the upwind and across-wind
;  dimensions and the area of the footprint.
; METHOD:
;  The upwind distances corresponding to a range of Zbar values is
;  calculated using the analytic expressions in Horst and Weil (1994)
;  and Horst and Weil (1995).  The 3D footprint function function is
;  then evaluated at Y=0 for these upwind distances. If the value
;  at the maximum upwind distance is greater than 0.1% of the function
;  maximum, the range of Zbar is extended until the function value at
;  maximum upwind distance is less than 0.1% of the function maximum.
;  The resulting values of Zbar and upwind distance, ZbAtX and XAtZb
;  respectively, are stored in a common block and subsequent values
;  of Zbar at intermediate values of X are found by interpolation.
;  The maximum function value, FMax, and the location of the maximum,
;  XMax, are then found using a search routine (GOLDEN) since the spacing of
;  XAtZb can be rather coarse (~15m).  The 3D footprint function is then
;  integrated (INT_2D) over the range of upwind distances bounded by the
;  0.1% isopleth (Xp1 and Xp2).  The integral is usually lies in the range
;  1.00+/-0.05.
;
;  The upwind distances (Xp1 and Xp2) corresponding to fractions of the
;  function maximum are found using a root finding routine (RTBIS) and
;  the fractional contribution to the flux from the surface area bounded
;  by these is estimated by integrating (INT_2D) the function between the
;  limits Xp1 and Xp2.  Note that the order of integration, dydx, is the
;  reverse of that used in Schmid (1994).  This allows the Y coordinates
;  of the function isopleths to be solved explicitly rather than calculating
;  discrete coordinates (X,Y) and fitting a curve to these as suggested
;  in Schmid (1994).  The integration produces a table of contributions
;  corresponding to specified fractions of the function maximum.  Fractions
;  of the function maximum corresponding to specified contributions are
;  then obtained by interpolation and the upwind distances corresponding
;  to these fractions are estimated using a root finding procedure.  A
;  final table is then written which gives the fractional contribution
;  to the flux, the function value at this contribution, the upwind (Xp1
;  and Xp2) and across-wind (Ypm) distances corresponding to the fractional
;  contribution and the area of the bounding isopleth.
; USES:
;  USER PROCEDURES : All locations under IDL52\General
;   Name		Location	Description
;	Constants	Utilities	defines common block and sets various constants
;	Pause		Utilities	pauses procedure execution until user pushes a button
;	Vga			Graphics	defines colours and window sizes for screen
;	Write3DDat	FileIO		writes 3D data to an ASCII file for plotting with Surfer
;	WriteBLN	FileIO		writes line data to an ASCII file for plotting by Grapher
;  USER FUNCTIONS : All locations under IDL52\General
;   Name		Location	Description
;   AConst		Footprint	calculates the parameter A
;   BConst		Footprint	calculates the parameter b
;	Cleanstring	Functions	cleans leading and trailing white space from strings
;	Dy			Footprint	calculates the horizontal concentration distribution
;   dZbBydx		Footprint	calculates dZbar/dx at X
;	FPNAtXY_Int	Footprint	calculates SAW value at (X,Y), used during integration
;	FPNAtY0_Neg	Footprint	calculates CWI SAW at (X,Y0), used to find maximum value
;	FPNAtY0_Root Footprint	calculates CWI SAW at (X,Y0), used to find CWI SAW roots
;	GetLUN		Functions	returns the lowest free logical unit number
;	Golden		Numerical Recipes	searches for a function minimum
;	Phih		Functions	diabatic correction to temperature gradient
;   PSIFnZ		Footprint	calculates X at Zbar
;	Psim		Functions	diabatic correction to wind speed profile
;   Rtbis		Numerical Recipes	searches for a root of a function and
;									returns the location of the root if found
;   Shape		Footprint	calculates the shape parameter s
;	SigmaY		Footprint	calculates the lateral plume spread parameter
;   Uzbar		Footprint	calculates U(Zbar), the plume advection speed
;	YLimits		Footprint	calculates the Y limits for INT_2D given X values
;	ZBar		Footprint	calculates Zbar given X
;  SYSTEM PROCEDURES : All locations under IDL52\
;	Name		Location	Description
;	LOADCT		Lib			loads a pre-defined colour table
;  SYSTEM FUNCTIONS : All locations under IDL52\
;	Name		Location	Description
;	FILEPATH	Lib			returns the file path
;	GAMMA		Lib			gamma function
;	INTERPOL	Lib			linear interpolation
;	INT_2D		Lib			2D numerical integration of a function
;	POLY_AREA	Lib			calculates the area enclosed by a polygon
;	REVERSE		Lib			reverses the order of elements in an array

 COMMON Constants
 COMMON Colours
 COMMON SWF_Data, zm, z0, L, Us, SigmaTheta, ZbAtX, XAtZb, Ub, Zbx
 COMMON SWF_Const, c, p, FVal, r2PI, SigYMethod

; *** Set some control variables
; *** Set the measurement height, roughness length and meteorology.
 zm = 2.1 ;5 ;4.5 ;
 z0 = 0.02
 L =  -2000.	;-30.
 SigmaTheta = 26.0
 Us = 0.22	;0.5
 SigYMethod = 'P76'
; *** Define various local constants.
 p = 1.55		; PConst(s)										;1.55 at s=1.5
 c = 0.63		; b*EXP(A*b*QROMO('CIntFn',0.0000001,/MIDEXP))	;0.63 at s=1.5
 r2PI = SQRT(2.*!PI)
 NZb = 500 ;500
 MHgt = 20 ;20.0
; *** Clip the value of L to make believe that the aircraft is
; *** in the surface layer.  We will use a very generous definition
; *** of the depth of the surface layer.
 IF (zm/L LT -5.0) THEN L = -zm/5.0
; *** Calculate Zbar using the analytic expression for x(zbar) from
; *** HW94 Eqns A4 and A10 and the HW95 Correigenda.
 N = 0
Start:
 N = N + 1
 ZbAtX = (FINDGEN(NZb)*MHgt*zm/(NZb-1)) + 2*z0
 PSIFnZ0 = PSIFnZ(L, z0, z0, p)		;PSIFnZ returns DOUBLE
 XAtZb = z0*FLOAT(PSIFnZ(L, ZbAtX, z0, p) - PSIFnz0)
 ZbAtX = ZbAtX[WHERE(XAtZb GT 0.0)]
 XAtZb = XAtZb[WHERE(XAtZb GT 0.0)]
 NEle = N_ELEMENTS(XAtZb)
; *** Calculate dZb/dx, the rate of change of Zb with downwind distance.
 dZbdx = dzbbydx(L, ZbAtX, z0, p)
; *** Calculate Uzb, the mean advection speed of the plume.
 Uzb = Uzbar(ZbAtX, Us, L, z0, c)
; *** Calculate the shape parameter, s, and parameters A and b.
 s = Shape(ZbAtX, z0, L, c)
 A = aconst(s, /H94)
 b = bconst(s, /H94)
; *** Calculate the mean wind speed at the measurement height, zm.
 Ub = (Us/k)*(ALOG(zm/z0)-Psim(zm,L))
; *** Calculate the cross-wind integrated footprint function.
 CWIF = DOUBLE(dZbdx*zm*Ub*A*EXP(-(zm/(b*ZbAtX))^s)/(Uzb*ZbAtX^2))
 XMaxCWIF = XAtZb[WHERE(CWIF EQ MAX(CWIF))]
; *** Calculate the horizontal plume spread, SigY
 SigY = sigmay(SigmaTheta, XAtZb)
 SigV = SigmaTheta*!DTOR*Ub
; *** Calculate the 3D footprint function.
 FPNAtY0 = CWIF/DOUBLE(r2PI*SigY)
 XMax3D = XAtZb[WHERE(FPNAtY0 EQ MAX(FPNAtY0))]
; *** Get the maximum value of the footprint function, the upwind
; *** location of the maximum and set the limit to which the function
; *** will be integrated to 0.1% of the maximum.
 FMax = MAX(FPNAtY0)
 IF (FPNAtY0[NEle-1] GT 0.0001D*FMax) THEN BEGIN
  IF (n GE 50) THEN STOP,'More than 20 iterations in MHgt'
  MHgt = 1.25*MHgt
  NZb = 1.25*NZb
  GOTO, Start
 ENDIF
; *** Plot the cross-wind integrated footprint
 WINDOW, 0, TITLE='CWIF (left) and Cumulative CWIF (right)'
 PLOT, XAtZb, CWIF,ystyle=8
 PLOT, XAtZb,TOTAL(-1*CWIF*TS_DIFF(XAtZb,1),/CUMULATIVE),/NOERASE,xrange=!x.crange,ystyle=4,xstyle=1,line=2

 NEle = N_ELEMENTS(XAtZb)									; Number of elements
 Index = WHERE(FPNAtY0 EQ FMax)								; Location of maximum contribution
 X = [XAtZb[Index[0]-2],XAtZb[Index[0]],XAtZb[Index[0]+2]]	; First guess at bracketing triplet
; *** The routine used to find the maximum (actually the minimum) of the
; *** footprint function, Golden, has problems when the function values
; *** and tolerance (0.001*FMax in our case) get small (ie FMax~4E-5
; *** and tol~4E-8).  The problem is probably round-off error and
; *** might be cured by re-writing the routine to use double precision.
; *** Rather than do this, we will pass FMax to the function being
; *** minimised (FPNAtY0_Neg) by setting FVal to FMax.  FPNAtY0_Neg
; *** will then use FVal to normalise the footprint function so that
; *** its minimum value is approximately -1.
 FVal = FMax									; Set FVal for normalisation
 FMax = -1.*Golden(X,'FPNAtY0_Neg',0.001,XMax)	; Search for maximum
 FMax = FMax*FVal								; Undo normalisation
 FVal = FMax*0.0001D							; Integrate to 0.01% of maximum
; *** Select the data points that lie within the limits.
 LI = MIN(WHERE(FPNAtY0 GE FVal))
 RI = MAX(WHERE(FPNAtY0 GE FVal))
; *** Get the Y coordinates of the 0.01% isopleth.
 Num = DOUBLE(r2PI*SigY[LI:RI]*ZbAtX[LI:RI]^2*FVal*Uzb[LI:RI])
 Den = DOUBLE(dZbdx[LI:RI]*zm*Ub*A[LI:RI]*EXP(-(zm/(b[LI:RI]*ZbAtX[LI:RI]))^s[LI:RI]))
 YLim = SQRT(-2.D*SigY[LI:RI]^2*ALOG(Num/Den))
 XLim = XAtZb[LI:RI]
; *** Plot the 0.01% isopleth.
 WINDOW,1,TITLE='0.01% isopleth'
 PLOT,[XLim,REVERSE(XLim)],[YLim,-REVERSE(YLim)]

; *** Plot the footprint function.
 FVal = 0.01*FMax
 LI = MIN(WHERE(FPNAtY0 GE FVal))
 RI = MAX(WHERE(FPNAtY0 GE FVal))
 NPts = (RI - LI) + 1
 Num = DOUBLE(r2PI*SigY[LI:RI]*ZbAtX[LI:RI]^2*FVal*Uzb[LI:RI])
 Den = DOUBLE(dZbdx[LI:RI]*zm*Ub*A[LI:RI]*EXP(-(zm/(b[LI:RI]*ZbAtX[LI:RI]))^s[LI:RI]))
 ALn = ALOG(Num/Den)
 Index = WHERE(ALn > 0.0,Count)
 IF (Count GT 0) THEN ALn[Index] = 0.0
 YLim = SQRT(-2.D*SigY[LI:RI]^2*ALn)
 XLim = XAtZb[LI:RI]
 Ypm = FIX(MAX(YLim))
 YAtZb = (2.*Ypm/FLOAT(NPts-1))*INDGEN(NPts) - Ypm
 SWF = FLTARR(NPts,NPts)
 FOR i=0,NPts-1 DO BEGIN
  SWF[*,i] = DOUBLE(Dy(SigY[LI:RI], YAtZb[i])*dZbdx[LI:RI]*zm*Ub*A[LI:RI]*EXP(-(zm/(b[LI:RI]*ZbAtX[LI:RI]))^s[LI:RI])/(Uzb[LI:RI]*ZbAtX[LI:RI]^2))
 ENDFOR
 WINDOW, 2, TITLE='Source area weight function to 1% isopleth'
; SURFACE, SWF, XAtZb[LI:RI], YAtZb, /NODATA, /SAVE, $
 SURFACE, SWF, XAtZb[LI:RI], YAtZb, $
  XTITLE='Downwind Distance (m)', YTITLE='Crosswind Distance (m)', ZTITLE='SW Function', $
  YRANGE=[MIN(YAtZb),MAX(YAtZb)], XRANGE=[MIN(XAtZb[LI:RI]),MAX(XAtZb[LI:RI])]
; CONTOUR, SWF, XAtZb[LI:RI], YAtZb, /NOERASE, /T3D, NLEVELS=30, $
;  YRANGE=[MIN(YAtZb),MAX(YAtZb)], XRANGE=[MIN(XAtZb[LI:RI]),MAX(XAtZb[LI:RI])]
; CONTOUR, SWF, XAtZb[LI:RI], YAtZb, /NOERASE, /T3D, LEVELS=[0.01*FMax], $
;  YRANGE=[MIN(YAtZb),MAX(YAtZb)], XRANGE=[MIN(XAtZb[LI:RI]),MAX(XAtZb[LI:RI])]

; *** Integrate the source weight function using bivariate numerical
; *** integration with the Y integration limits expressed as a
; *** function of downwind distance.
 FVal = 0.0001D*FMax
 Xp2 = Rtbis('FPNAtY0_Root',[XMax,XAtZb[NEle-1]],0.01)
 PLim = INT_2D('FPNAtXY_Int',[0.0,Xp2],'YLimits',20,/DOUBLE)
 PRINT,'      zm','      z0','           L', '   SigWD', '      u*', '   u(zm)','    SigV'
 PRINT,zm,z0,L,SigmaTheta,Us,Ub,SigV,FORMAT='(2F8.2,E12.2,4F8.2)'
 PRINT,'        FMax','    XMax','     Zbx','    PLim','    MHgt','     Nzb','       N'
 PRINT,FMax,XMax,Zbx,PLim,MHgt,Nzb,N,FORMAT='(E12.2,4F8.2,2I8)'
; *** Now get the fractional contribution to the flux at a range of
; *** source weight function values.
 FLev = [0.001,0.01,0.02,0.04,0.06,0.08,0.1,0.15,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.975,0.99]
 NLev = N_ELEMENTS(FLev)
 Xp1 = FLTARR(NLev)
 Xp2 = FLTARR(NLev)
 Pf = FLTARR(NLev)
 FOR i=0, NLev-1 DO BEGIN
  FVal = 0.0
  FVal = 1.01*MAX([FMax*FLev[i],FPNAtY0_Root(XMax/20)])
  Xp1[i] = Rtbis('FPNAtY0_Root',[XMax/20,XMax],0.01)
  Xp2[i] = Rtbis('FPNAtY0_Root',[XMax,XAtZb[NEle-1]],0.01)
  Pf[i] = INT_2D('FPNAtXY_Int',[Xp1[i],Xp2[i]],'YLimits',20,/DOUBLE)
  IF (i EQ 0) THEN PRINT, '    Flev','       Fval','      Pf','     Xp1','     Xp2'
  PRINT, FLev[i],FVal,Pf[i],Xp1[i],Xp2[i], $
   FORMAT='(F8.3,E11.3,F8.3,2F8.1)'
 ENDFOR
; *** Interpolate the source weight function values from the
; *** irregularly spaced integrals, Pf, to regularly spaced
; *** integral values.  The interpolated source weight function
; *** values then represent the levels to which the function
; *** must be integrated to give fractional contributions to
; *** the flux of 10%, 20%, 30% etc.
; *** NOTE: I have been unable to find a general function that
; ***       fits these points for the full stability range of
; ***       0 > z/L > -2
 PfInt = [0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1]
 FFit = INTERPOL(REVERSE(FLev),REVERSE(Pf),PfInt)
; *** Plot the percentage contribution to the flux as a function of
; *** the fraction of Fmax and work out the best fit.
 WINDOW, 3, TITLE='Contribution versus fraction of Fmax'
 PLOT, FLev, Pf, /NODATA, $
  XRANGE=[0,1], YRANGE=[0,1], $
  XTITLE='Fraction of Fmax',YTITLE='Contribution to Flux'
 OPLOT, FLev, Pf, PSYM=2
 OPLOT, FFit, PfInt, PSYM=1
; *** Now calculate the source area dimensions at the function levels
; *** corresponding to the fractional contributions in PfInt.
 NLev = N_ELEMENTS(FFit)
 Xp1f = FLTARR(NLev)
 Xp2f = FLTARR(NLev)
 PfFit = FLTARR(NLev)
 Ar = FLTARR(NLev)
 Ypm = FLTARR(NLev)
 NEle = 250
 FOR i=0, Nlev-1 DO BEGIN
  FVal = 0.0
  FVal = 1.01*MAX([FMax*FFit[i],FPNAtY0_Root(XMax/20),FPNAtY0_Root(MAX(XAtZb))])
  Xp1f[i] = Rtbis('FPNAtY0_Root',[XMax/20,XMax],0.01)
  Xp2f[i] = Rtbis('FPNAtY0_Root',[XMax,MAX(XAtZb)],0.01)
  PfFit[i] = INT_2D('FPNAtXY_Int',[Xp1f[i],Xp2f[i]],'YLimits',20,/DOUBLE)
  Xf = ((Xp2f[i]-Xp1f[i])/(NEle-1))*FINDGEN(NEle) + Xp1f[i]
  Xf = Xf[1:NEle-2]							; Dont use the 2 end points because of round-off error
  Zb = Zbar(ZbAtX, XAtZb, Xf)				; Get Zb at Xf
  sY = Shape(Zb, z0, L, c)
  AY = AConst(sY, /H94)
  bY = BConst(sY, /H94)
  dZbdx = dZbBydx(L, Zb, z0, p)
  SigY = SigmaY(SigmaTheta, Xf)
  Uzb = Uzbar(Zb, Us, L, z0, c)
  Num = r2PI*SigY*Zb^2*FVal*Uzb
  Den = dZbdx*zm*Ub*AY*EXP(-(zm/(bY*Zb))^sY)
  Yf = SQRT(-2*SigY^2*ALOG(Num/Den))		; Y coordinate of isopleth
  Xf = [Xp1f[i],Xf,Xp2f[i]]					; Put the 2 end points back in
  Yf = [0.0,Yf,0.0]  						; Force Y coordinate to 0 at end points
  Xp = [Xf,REVERSE(Xf)]
  Yp = [Yf,-1.*REVERSE(Yf)]
  IF (i EQ 0) THEN BEGIN
   WINDOW, 4, TITLE='Isopleths at 10%, 20% etc'
   PLOT, [Xf,REVERSE(Xf)], [Yf,-REVERSE(Yf)], /NODATA
   OPLOT, Xp, Yp
  ENDIF ELSE BEGIN
   OPLOT, Xp, Yp
  ENDELSE
  Ar[i] = POLY_AREA(Xp, Yp)
  Ypm[i] = MAX(Yp)
  IF (i EQ 0) THEN BEGIN
   PRINT, '       Fval','   PfFit','     Xp1','     Xp2','     Ypm','      Ar'
  ENDIF
  PRINT, Fval,PfFit[i],Xp1f[i],Xp2f[i],Ypm[i],Ar[i], $
   FORMAT='(E11.3,F8.3,3F8.1,I8)'
 ENDFOR
END
; *** Start of routines called by main program ***
FUNCTION AConst, s, K97=K97, H94=H94
 CASE 1 OF
  KEYWORD_SET(K97):RETURN, ((GAMMA(1./s))^1.5)/(s*SQRT(GAMMA(3./s)))
  KEYWORD_SET(H94):RETURN, s*GAMMA(2./s)/(GAMMA(1./s)*GAMMA(1./s))
  ELSE:RETURN, s*GAMMA(2./s)/(GAMMA(1./s)*GAMMA(1./s))
 ENDCASE
END

FUNCTION BConst, s, K97=K97, H94=H94
 CASE 1 OF
  KEYWORD_SET(K97):RETURN, SQRT(GAMMA(1./s))/SQRT(GAMMA(3./s))
  KEYWORD_SET(H94):RETURN, GAMMA(1./s)/GAMMA(2./s)
  ELSE:RETURN, GAMMA(1./s)/GAMMA(2./s)
 ENDCASE
END

FUNCTION DY, SigY, Y
; PURPOSE
;  Function to return the cross-wind concentration distribution.
 Dy = EXP(-0.5*(Y/SigY)^2)/(SQRT(2.*!PI)*SigY)
 RETURN, Dy
END

FUNCTION dzbbydx, L, zb, z0, p
 COMMON Constants
 pzb = p*zb
 a = phih(pzb,L)
 RETURN, k^2/((ALOG(pzb/z0)-psim(pzb,L))*a)
END
; FINDEX

FUNCTION FPNAtXY_Int, X, Y
; PURPOSE:
;  This function returns the 3D footprint function evaluated at the points
;  X and Y.  It is used by the routine INT_2D to integrate the footprint
;  function over user specified X and Y limits.
; INPUT (EXPLICIT):
;  X - upwind distance, scalar or 1D array, m
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data) - Zbar at upwind distances XAtZb, m
;  XAtZb (SWF_Data) - upwind distances at which ZbAtX defined, m
;  zm    (SWF_Data) - observation height, m
;  z0    (SWF_Data) - roughness length, m
;  L     (SWF_Data) - Monin-Obukhov length, m
;  Ub    (SWF_Data) - mean wind speed at observation height zm, m/s
;  Us    (SWF_Data) - friction velocity, m/s
;  SigmaTheta (SWF_Data) - standard deviation of wind direction, deg
;  c     (SWF_Const)
;  p     (SWF_Const)
; OUTPUT:
;  FPNAtXY - value of 3D footprint function at (X,Y)
; AUTHOR: PRI
; DATE: 23/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)
 s = Shape(ZbAtX, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 dZbdx = dZbBydx(L, Zb, z0, p)
 SigY = SigmaY(SigmaTheta, X)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 FPNAtXY = Dy(SigY, Y)*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)
 RETURN, DOUBLE(FPNAtXY)
END

FUNCTION FPNAtY0_Neg, X
; PURPOSE:
;  This function returns the negative of the footprint function
;  evaluated at Y = 0 for a range of X values.  It is used to
;  determine the maximum of the footprint function and the location
;  of the maximum.  The routine that performs the optimisation,
;  Golden, searches for a minimum, hence the use of the negative
;  of the footprint function in this routine (searching for a
;  minimum in the negative of a function is equivalent to
;  searching for a maximum in the function itself).
;
;  Note that the function is normalised by dividing by the maximum
;  value of the function (in FVal).  This is done to avoid problems
;  with round-off error encountered when the value of the function
;  gets small (FMax~4E-5).
; INPUT (EXPLICIT):
;  X - upwind distance at which to evaluate the negative of the footprint
;      function
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data)  - mean plume height, m
;  XAtZb (SWF_Data)  - upwind distances corresponding to ZbAtX, m
;  zm    (SWF_Data)  - measurement height, m
;  z0    (SWF_Data)  - roughness length, m
;  L     (SWF_Data)  - Monin-Obukhov length, m
;  Ub    (SWF_Data)  - mean wind speed at zm, m/s
;  Us    (SWF_Data)  - friction velocity, m/s
;  SigmaTheta (SWF_Data) - standard deviation of wind direction, deg
;  FVal  (SWF_Const) - value used to normalise the function so that the
;                      minimum value of CWIF_Neg is close to -1, this is
;                      done to avoid round-off errors
;  p     (SWF_Const)
;  c     (SWF_Const)
; OUTPUT:
;  -1*CWIF/FVal - returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zbx = Zbar(ZbAtX, XAtZb, X)
 s = Shape(Zbx, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 SigY = SigmaY(SigmaTheta, X)
 dZbdx = dZbBydx(L, Zbx, z0, p)
 Uzb = Uzbar(Zbx, Us, L, z0, c)
 RETURN, DOUBLE(-1.*dZbdx*zm*Ub*A*EXP(-(zm/(b*Zbx))^s)/(Zbx^2*Uzb)/(FVal*r2PI*SigY))
END

FUNCTION FPNAtY0_Root, X
; PURPOSE:
;  This function returns the value of the 3D footprint function
;  at the upwind distance X and Y=0 (FPNAtY0) minus a specified
;  function value, FVal.  It is used by the root finding function
;  (Rtbis) to estimate the upwind distances corresponding to
;  particular values of the 3D footprint function.
; INPUT (EXPLICIT):
;  X - upwind distance at which to evaluate the cross-wind
;      integrated footprint function
; INPUT (IMPLICIT):
;  ZbAtX (SWF_Data)  - mean plume height, m
;  XAtZb (SWF_Data)  - upwind distances corresponding to ZbAtX, m
;  zm    (SWF_Data)  - measurement height, m
;  z0    (SWF_Data)  - roughness length, m
;  L     (SWF_Data)  - Monin-Obukhov length, m
;  Ub    (SWF_Data)  - mean wind speed at zm, m/s
;  Us    (SWF_Data)  - friction velocity, m/s
;  SigmaTheta (SWF_Data) - standard deviation of wind direction, deg
;  FVal  (SWF_Const) - value to be subtracted from the calculated footprint
;                      function, this is the function value for which RTBIS
;                      will determine the X location
;  p     (SWF_Const)
;  c     (SWF_Const)
; OUTPUT:
;  FPNAtY0-FVal - returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)
 s = Shape(Zb, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 SigY = SigmaY(SigmaTheta, X)
 dZbdx = dZbBydx(L, Zb, z0, p)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 FPNAtY0 = DOUBLE(dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s)/(Zb^2*Uzb)/(r2PI*SigY))
 RETURN, DOUBLE(FPNAtY0)-DOUBLE(FVal)
END

FUNCTION Golden, X, func, tol, xmin
;
; PURPOSE:
;  Given a function, "func", and given a bracketing triplet of abscissas, X,
;  such that X[1] is between X[0] and X[2] and f(X[1]) is less than both
;  f(X[0]) and f(X[2]), this routine performs a golden search for the
;  minimum, isolating it to a fractional precision of about "tol".  The
;  abscissa of the minimum is returned as "xmin" and the function value
; is returned as "Golden".
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., 394-395
; DATE: ??03/2002
;
 R = 0.61803399
 C = 1.0 - R
 ax = X[0] & bx = X[1] & cx = X[2]
 x0 = ax
 x3 = cx
 CASE 1 OF
  (ABS(cx-bx) GT ABS(bx-ax)): BEGIN
   x1 = bx
   x2 = bx + C*(cx-bx)
   END
  ELSE: BEGIN
   x2 = bx
   x1 = bx - C*(bx-ax)
   END
 ENDCASE
 f1 = CALL_FUNCTION(func, x1)
 f2 = CALL_FUNCTION(func, x2)
 WHILE (ABS(x3-x0) GT tol*(ABS(x1)+ABS(x2))) DO BEGIN
  CASE 1 OF
   (f2 LT f1): BEGIN
    x0 = x1
    x1 = x2
    x2 = R*x1 + C*x3
    f1 = f2
    f2 = CALL_FUNCTION(func, x2)
    END
   ELSE: BEGIN
    x3 = x2
    x2 = x1
    x1 = R*x2 + C*x0
    f2 = f1
    f1 = CALL_FUNCTION(func, x1)
    END
  ENDCASE
 ENDWHILE
 CASE 1 OF
  (f1 LT f2): BEGIN
   Golden = f1
   xmin = x1
   END
  ELSE: BEGIN
   Golden = f2
   xmin = x2
   END
 ENDCASE
 RETURN, Golden
END
; INT_2D

; INTERPOL


FUNCTION PSIFnZ, L, z, z0, p
; *** Function to evaluate Eqn A10 from Horst and Weil (1994).  Eqn
; *** A10 provides an exact solution of the change in mean plume
; *** height with downwind distance.  This is an alternative to the
; *** usual approach of integrating numerically Eqn 8 in HW94.
; *** NOTES:
; ***  1) Equation A10 in Horst and Weil 1994 was incorrect, the
; ***     correct equation was published in a Corrigenda in
; ***     JAOT, 12, April 1995, p 447.
; ***  2) HW94 and HW95 use a different form for the psim function
; ***     than the one used here (see Paulson 1970).
 COMMON Constants
 IF (1./L GE 0.0) THEN BEGIN
  T1 = DOUBLE(z/(k^2*z0))
  T2 = DOUBLE(ALOG(p*z/z0))
  T3 = 1.D
  T4 = DOUBLE(5.D*p*z/L)
  T5 = DOUBLE(0.25+(5.*p*z/(3.*L))+0.5*ALOG(p*z/z0))
  RETURN, T1*(T2-T3+T4*T5)
 ENDIF ELSE BEGIN
  Yp = DOUBLE((1.D - 16.D*p*z/L)^0.25)
  T1 = DOUBLE((1.D/k^2)*2.D*ABS(L)/(16.D*p*z0))
  T2 = DOUBLE(Yp^2)*(ALOG(p*z/z0)-psim(p*z,L))
  T3 = DOUBLE(2.D*ATAN(Yp))
  T4 = DOUBLE(ALOG((Yp+1.D)/(Yp-1.D)))
  T5 = DOUBLE(4.D*Yp)
  RETURN, T1*(T2+T3+T4-T5)
 ENDELSE
END

FUNCTION psim, z, L
  IF (L LT 0) THEN BEGIN
    x = (1.0 - 16.0*z/L)^0.25
    result = 2.0*ALOG((x+1.0)/2.0)+ALOG((x^2+1)/2.0)-2.0*ATAN(x)+!PI/2.0
  ENDIF ELSE BEGIN
    result = -5.0*z/L
  ENDELSE
  RETURN, result
END

FUNCTION phih, z, L
  IF (L LT 0) THEN BEGIN
    result = 1.0/(1.0 - 16.0*z/L)^0.5
  ENDIF ELSE BEGIN
    result = (1.0 +  5.0*z/L)
  ENDELSE
  RETURN, result
END
; POLY_AREA

FUNCTION RTBis, Func, xbrac, Acc
;
; PURPOSE:
;  Using bisection, find the root of a function, "Func", known to lie
;  between xbrac[0] and xbrac[1].  The root, returned as RTBIS, will be
;  refined until its accuracy is +/-Acc.
; INPUT:
;  Func  - scalar string containing the name of the function
;  xbrac - 1D array containing 2 elements that are abscissa values
;          bracketing the root
;  Acc   - accuracy, in +/- abscissa units, to which the root will
;          be refined
; OUTPUT:
;  RTBis - the function returns the root to the within the specified
;          accuracy
; AUTHOR:
;  PRI, copied from Numerical Recipes in F77, 2nd Ed., 347
;
 x1 = xbrac[0] & x2 = xbrac[1]
 fmid = CALL_FUNCTION(Func, x2)
 f = CALL_FUNCTION(Func, x1)
 IF (f*fmid GE 0.0) THEN BEGIN
  PRINT,x1,x2
  PRINT,f,fmid
  STOP, 'RTBIS: Bracket values do not enclose a root'
 ENDIF
 IF (f LT 0.0) THEN BEGIN
  RTBis = x1
  dx = x2 - x1
 ENDIF ELSE BEGIN
  RTBis = x2
  dx = x1 - x2
 ENDELSE
 FOR i = 1, 40 DO BEGIN
  dx = dx*0.5
  xmid = RTBis + dx
  fmid = CALL_FUNCTION(Func, xmid)
  IF (fmid LE 0.0) THEN RTBis = xmid
;  print,i,dx,Acc,fmid,RTBis,xmid
  IF (ABS(dx) LT Acc OR fmid EQ 0.0) THEN RETURN, RTBis
 ENDFOR
 STOP, 'RTBis: Root not found after 40 bisections'
END

FUNCTION Shape, zb, z0, L, c
; PURPOSE:
;  This function returns the value of the shape parameter.  The expressions
;  used come from Finn et al (1996).
; INPUT:
;  zb - mean plume height, m
;  z0 - roughness length, m
;  L  - Monin-Obukhov length, m
;  c  - fraction of mean plume height at which the mean wind speed
;       equals the plume advection speed
; OUTPUT:
;  s - value of the shape parameter, returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 IF (1./L GT 0.) THEN $
  s = ((1.+5.*c*zb/L)/(ALOG(c*zb/z0)-psim(c*zb,L))) + (1.+10.*c*zb/L)/(1.+5.*c*zb/L)
 IF (1./L LE 0.) THEN $
  s = (1./((ALOG(c*zb/z0)-psim(c*zb,L))*(1.-16.*c*zb/L)^0.25)) + (1.-8.*c*zb/L)/(1.-16.*c*zb/L)
 RETURN, s
END

FUNCTION SigmaY, SigmaTheta, X
; PURPOSE:
;  Function to calculate the horizontal plume spread from
;  the standard deviation of wind direction and the
;  downwind distance.
; INPUT:
;  SigmaTheta - standard deviation of wind direction, deg
;  X          - downwind distance, m
  SigY = SigmaTheta*!DTOR*X/(1.+0.0208*SQRT(X))
  RETURN, SigY
END
; TS_DIFF

FUNCTION Uzbar, Zb, ustar, L, z0, c
 COMMON Constants
 CASE 1 OF
  (1./L GT 0.): RETURN, (ustar/k)*(ALOG(c*Zb/z0)+4.7*Zb/L)
  (1./L LE 0.): RETURN, (ustar/k)*(ALOG(c*Zb/z0)-Psim(c*Zb,L))
 ENDCASE
END

FUNCTION YLimits, X
;
; PURPOSE:
;  This function returns the Y coordinates of the footprint function
;  isopleth FVal (FVal is passed in the common block SWF_Const) at
;  the specified X coordinate (X is passed as an argument to this
;  function).  This routine is used by INT_2D to integrate the
;  footprint function over a specified range of X coordinates.
;  Note that the isopleth is symmetrical about the X axis so that
;  a single X value corresponds to a positive and a negative Y
;  value.
;
 COMMON Constants
 COMMON SWF_Data
 COMMON SWF_Const
 Zb = Zbar(ZbAtX, XAtZb, X)
 s = Shape(Zb, z0, L, c)
 A = AConst(s, /H94)
 b = BConst(s, /H94)
 dZbdx = dZbBydx(L, Zb, z0, p)
 SigY = SigmaY(SigmaTheta, X)
 Uzb = Uzbar(Zb, Us, L, z0, c)
 Num = DOUBLE(SQRT(2*!PI)*SigY*Zb^2*FVal*Uzb)
 Den = DOUBLE(dZbdx*zm*Ub*A*EXP(-(zm/(b*Zb))^s))
 Arg1 = Num/Den
 IF Arg1 LE 0.0 THEN STOP,'YLimts: Arg1 is negative or zero'
 Arg2 = -2.D*SigY^2*ALOG(Arg1)
 IF Arg2 LT 0.0D THEN Arg2 = 0.0D
 YPos =  SQRT(Arg2)
 YNeg = -SQRT(Arg2)
 RETURN,[YNeg,YPos]
END

FUNCTION Zbar, ZbAtX, XAtZb, X
 Zb = INTERPOL(ZbAtX,XAtZb,X)
 IF (SIZE(X,/N_DIMENSIONS) NE 0) THEN RETURN, Zb ELSE RETURN, Zb[0]
END
