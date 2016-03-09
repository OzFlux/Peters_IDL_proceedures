PRO FPN
; PURPOSE:
;  This procedure calculates the cross-wind integrated source area (footprint)
;  weights for a range of upwind distances using the approximate form from
;  Horst and Weil (1994), the exact form from Horst and Weil (1992) and the
;  form given in Kaharabat et al (1997).  It plots the normalised CWI source-
;  area weights with points digitised from Figure 2 of Horst (1999) overlaid
;  and the cummulative weights with increasing upwind distance.  It then does
;  the same for the straight (non-normalised) CWI source-area weights.
;
;  The procedure was designed to check the implementation of the source-area
;  routines in IDL by comparing the calculated values with those digitised
;  from Horst (1999) and also to compare the approximate method of Horst
;  and Weil (1994) with the method of Kaharabata (1997).
; INPUTS:
;  No explicit inputs but various physical parameters need to be specified
;  at the start of the procedure code.
; OUTPUTS:
;  GRAPHIC
;   - plot of normailised CWI source-area weights with upwind distance with
;     points digitised from Horst (1999) overlaid for conditions matching
;     those in H99 Figure 2
;   - plot of cummulative, normalised CWI source-area weight with upwind
;     distance, should approach unity for large upwind distances
;   - plot of CWI source area weights (not normalised) with upwind distance
;   - plot of cummulative CWI source area weights (not normalised) with
;     upwind distance
;  FILE
;   - D:\OASIS95\FOOTPRINT\K97NORM.DAT, normalised CWI source-area weights
;     using Kaharabata et al (1997)
;   - D:\OASIS95\FOOTPRINT\H94NORM.DAT, normalised CWI source-area weights
;     using Horst and Weil (1994)
;   - D:\OASIS95\FOOTPRINT\K97CWIF.DAT, CWI source-area weights using K97
;   - D:\OASIS95\FOOTPRINT\H94CWIF.DAT, CWI source-area weights using H94
; METHOD:
; USES:
; AUTHOR: PRI
; DATE: January 2003

 COMMON Colours
 vga

 zm = 9.0		; Measurement height	(H99 9.0)
 z0 = 0.03		; Roughness length		(H99 0.03)
 L =  30.		; Monin-Obukhov length	(H99 -30)
 Us = 0.5		; Friction velocity		(H99 0.5)
 MZb = 10.*zm
 NZb = 500
 Save = 'Y'

; *** Calculate the normalised cross-wind integrated footprint.
 N = 0
DOK97:
 N = N + 1
 FPN = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /K97, /NORMALISE)
 FMax = MAX(FPN.Weights)
 NEle = N_ELEMENTS(FPN.Distance)
 IF (FPN.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
  MZb = 1.25*MZb
  NZb = 1.25*NZb
  GOTO, DOK97
 ENDIF
 UB = MAX(WHERE(FPN.Weights GE 0.001*FMax))
 K97Weights = FPN.Weights[0:UB]
 K97Distance = FPN.Distance[0:UB]
 K97Zb = FPN.Zb[0:UB]
 MZb = 10.*zm
 NZb = 500
 N = 0
DOH94:
 N = N + 1
 FPN = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /H94, /NORMALISE)
 FMax = MAX(FPN.Weights)
 NEle = N_ELEMENTS(FPN.Distance)
 IF (FPN.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
  MZb = 1.25*MZb
  NZb = 1.25*NZb
  GOTO, DOH94
 ENDIF
 UB = MAX(WHERE(FPN.Weights GE 0.001*FMax))
 H94Weights = FPN.Weights[0:UB]
 H94Distance = FPN.Distance[0:UB]
 H94Zb = FPN.Zb[0:UB]
; MZb = 10.*zm
; NZb = 500
; N = 0
;DOXCT:
; N = N + 1
; FPN_XCT = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /XCT, /NORMALISE)
; FMax = MAX(FPN_XCT.Weights)
; NEle = N_ELEMENTS(FPN_XCT.Distance)
; IF (FPN_XCT.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
;  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
;  MZb = 1.25*MZb
;  NZb = 1.25*NZb
;  GOTO, DOXCT
; ENDIF
 WINDOW, 0, TITLE='Normalised cross-wind integrated source-area weights'
 PLOT,K97Zb/zm, K97Weights, /NODATA, /XLOG, /YLOG, XRANGE=[0.1,10], YRANGE=[0.01,1.0]
 OPLOT, K97Zb/zm, K97Weights, COLOR=white
 OPLOT, H94Zb/zm, H94Weights, COLOR=blue
; OPLOT, FPN_XCT.Zb/zm, FPN_XCT.Weights, COLOR=yellow
; *** Plot the cross-wind integrated footprint function and compare
; *** it with values read from Horst (1999), Figure 2.
 IF (zm/L EQ -0.3 AND zm/z0 EQ 300.) THEN BEGIN
  F_H99 = [0.01,0.05,0.10,0.50,0.65,0.5,0.36,0.1,0.05,0.036,0.013]
  X_H99 = [0.12,0.145,0.16,0.27,0.43,0.77,1.0,2.6,4.0,5.0,10.0]
  OPLOT, X_H99, F_H99, PSYM=2, COLOR=blue
 ENDIF
 IF (zm/L LT 1E-3 AND zm/L GT -1E-3 AND zm/z0 EQ 300.) THEN BEGIN
  F_H99 = [0.01,0.05,0.1,0.5,0.76,0.5,0.46,0.1,0.05,0.027,0.01]
  X_H99 = [0.13,0.16,0.19,0.28,0.47,0.92,1.0,2.51,3.66,5.0,8.11]
  OPLOT, X_H99, F_H99, PSYM=2, COLOR=blue
 ENDIF
 IF (zm/L EQ 0.3 AND zm/z0 EQ 300.) THEN BEGIN
  F_H99 = [0.01,0.05,0.10,0.5,0.95,0.5,0.1,0.05,0.013,0.01]
  X_H99 = [0.15,0.18,0.2,0.28,0.5,1.0,2.2,3.0,5.0,5.6]
  OPLOT, X_H99, F_H99, PSYM=2, COLOR=blue
 ENDIF
 dZb_K97 = Centreddifference(K97Zb,INDGEN(N_ELEMENTS(K97Zb)))
 dZb_H94 = Centreddifference(H94Zb,INDGEN(N_ELEMENTS(H94Zb)))
 CWgt_K97 = RunSum(K97Weights*dZb_K97/zm)
 CWgt_H94 = RunSum(H94Weights*dZb_H94/zm)
 WINDOW, 1, TITLE='Cumulative normalised cross-wind integrated footprint'
 PLOT, H94Distance,CWgt_H94, /NODATA, YRANGE=[0.0,1.2]
 OPLOT, K97Distance, CWgt_K97, COLOR=white
 OPLOT, H94Distance, CWgt_H94, COLOR=blue
 IF Save EQ 'Y' THEN BEGIN
  OutFile = 'D:\OASIS95\FOOTPRINT\K97NORM.DAT'
  FCHeader = 'Normalised cross-wind integrated footprint: K97 '+STRING(zm)+STRING(z0)+STRING(L)+STRING(Us)
  PutSer, D1, K97Distance, 'X'
  PutSer, D1, K97Zb, 'Zb'
  PutSer, D1, K97Weights, 'FPN_K97'
  PutSer, D1, CWgt_K97, 'CFPN_K97'
  PutFC, OutFile, D1, FCHeader, '(4E12.3)'
  NEle = N_ELEMENTS(CWgt_H94)
  OutFile = 'D:\OASIS95\FOOTPRINT\H94NORM.DAT'
  FCHeader = 'Normalised cross-wind integrated footprint: H94 '+STRING(zm)+STRING(z0)+STRING(L)+STRING(Us)
  PutSer, D2, H94Distance, 'X'
  PutSer, D2, H94Zb, 'Zb'
  PutSer, D2, H94Weights, 'FPN_H94'
  PutSer, D2, CWgt_H94/CWgt_H94[NEle-1], 'CFPN_H94'
  PutFC, OutFile, D2, FCHeader, '(4E12.3)'
 ENDIF

 PRINT,'           L','      U*','     z/L','     K97','     H94'
 PRINT, L, Us, zm/L, $
  CWgt_K97[N_ELEMENTS(CWgt_K97)-1], CWgt_H94[N_ELEMENTS(CWgt_H94)-1], $
  FORMAT='(E12.3,4F8.2)'

; *** Calculate the cross-wind integrated footprint.
 MZb = 10.*zm
 NZb = 500
 N = 0
DOK97B:
 N = N + 1
 FPN = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /K97)
 FMax = MAX(FPN.Weights)
 NEle = N_ELEMENTS(FPN.Distance)
 IF (FPN.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
  MZb = 1.25*MZb
  NZb = 1.25*NZb
  GOTO, DOK97B
 ENDIF
 UB = MAX(WHERE(FPN.Weights GE 0.001*FMax))
 K97Weights = FPN.Weights[0:UB]
 K97Distance = FPN.Distance[0:UB]
 K97Zb = FPN.Zb[0:UB]
 MZb = 10.*zm
 NZb = 500
 N = 0
DOH94B:
 N = N + 1
 FPN = XWindIntFPN(zm, z0, L, Us, MZb, NZb, /H94)
 FMax = MAX(FPN.Weights)
 NEle = N_ELEMENTS(FPN.Distance)
 IF (FPN.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
  MZb = 1.25*MZb
  NZb = 1.25*NZb
  GOTO, DOH94B
 ENDIF
 UB = MAX(WHERE(FPN.Weights GE 0.001*FMax))
 H94Weights = FPN.Weights[0:UB]
 H94Distance = FPN.Distance[0:UB]
 H94Zb = FPN.Zb[0:UB]
; MZb = 10.*zm
; NZb = 500
; N = 0
;DOXCTB:
; N = N + 1
; FPN_XCT = CWIFExact(zm, z0, L, Us, MZb, NZb)
; FMax = MAX(FPN_XCT.Weights)
; NEle = N_ELEMENTS(FPN_XCT.Distance)
; IF (FPN_XCT.Weights[NEle-1] GT 0.001*FMax) THEN BEGIN
;  IF (N GE 20) THEN STOP,'FPN: More than 20 calls to XWindIntFPN'
;  MZb = 1.25*MZb
;  NZb = 1.25*NZb
;  GOTO, DOXCTB
; ENDIF
 WINDOW, 2, TITLE='Cross-wind integrated source-area weights'
 PLOT,K97Distance, K97Weights, /NODATA
 OPLOT, K97Distance, K97Weights, COLOR=white
 OPLOT, H94Distance, H94Weights, COLOR=blue
; OPLOT, FPN_XCT.Distance, FPN_XCT.Weights, COLOR=yellow
 dX_K97 = Centreddifference(K97Distance,INDGEN(N_ELEMENTS(K97Distance)))
 dX_H94 = Centreddifference(H94Distance,INDGEN(N_ELEMENTS(H94Distance)))
 CWgt_K97 = RunSum(K97Weights*dX_K97)
 CWgt_H94 = RunSum(H94Weights*dX_H94)
 WINDOW, 4, TITLE='Cumulative cross-wind integrated footprint'
 PLOT, H94Distance,CWgt_H94, /NODATA, YRANGE=[0.0,1.2]
 OPLOT, K97Distance, CWgt_K97, COLOR=white
 OPLOT, H94Distance, CWgt_H94, COLOR=blue

 IF Save EQ 'Y' THEN BEGIN
  NEle = N_ELEMENTS(CWgt_K97)
  OutFile = 'D:\OASIS95\FOOTPRINT\K97CWIF.DAT'
  FCHeader = 'Cross-wind integrated footprint: K97 '+STRING(zm)+STRING(z0)+STRING(L)+STRING(Us)
  PutSer, D3, K97Distance, 'X'
  PutSer, D3, K97Zb, 'Zb'
  PutSer, D3, K97Weights, 'FPN_K97'
  PutSer, D3, CWgt_K97, 'CFPN_K97'
  PutFC, OutFile, D3, FCHeader, '(4E12.3)'
  NEle = N_ELEMENTS(CWgt_H94)
  OutFile = 'D:\OASIS95\FOOTPRINT\H94CWIF.DAT'
  FCHeader = 'Cross-wind integrated footprint: H94 '+STRING(zm)+STRING(z0)+STRING(L)+STRING(Us)
  PutSer, D4, H94Distance, 'X'
  PutSer, D4, H94Zb, 'Zb'
  PutSer, D4, H94Weights, 'FPN_H94'
  PutSer, D4, CWgt_H94/CWgt_H94[NEle-1], 'CFPN_H94'
  PutFC, OutFile, D4, FCHeader, '(4E12.3)'
 ENDIF
 PRINT,'Hello sailor'
END