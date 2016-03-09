PRO ZbarChk
; *** Procedure to compare zbar calculated by the analytical and
; *** numerical integration methods.

 COMMON Constants
 COMMON Colours
 COMMON FPN_Parameters, zm, z0, L

 zm = 10.0
 L = -1000000.0
 z0 = 0.1
 s = 1.3
 XMax = 2000.

 p = (s*(GAMMA(2.0/s)/GAMMA(1.0/s))^s)^(1.0/(1.0-s))

 MaxX = ZbarFnX(XMax)
 Xd1 = FINDGEN(FIX(MaxX))
 Zb1 = Zbar(Xd1)
 WINDOW,0, TITLE='Zbar = f(x)'
 PLOT, Xd1, Zb1, /NODATA
 OPLOT, Xd1, Zb1, COLOR=blue

 MaxX = ZbarFnX(XMax,/ANALYTIC)
 Xd2 = FINDGEN(FIX(MaxX))
 Zb2 = Zbar(Xd2)
 OPLOT, Xd2, Zb2, COLOR=yellow

 WINDOW,1
 PLOT,Xd2[0:20],Zb2[0:20],/NODATA
 OPLOT,Xd1[0:20],Zb1[0:20],COLOR=blue
 OPLOT,Xd2[0:20],Zb2[0:20],COLOR=yellow

; ZbDiff = Zb1[Index] - Zb2[Index]
; WINDOW,1, TITLE='Zbar: Numerical minus analytical'
; PLOT, XDist[Index], ZbDiff[Index]
; PRINT, 'Just a dummy...'

END