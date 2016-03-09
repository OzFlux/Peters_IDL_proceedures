PRO fwNDVI, GenFile
; PURPOSE:
;
; INPUT:
;
; OUTPUT:
;
; AUTHOR:
;
; MODS DONE:
;
; MODS REQUIRED:
;  1) calculate footprint weights for all aircraft locations not just those
;     reported in the transect flux files.
;  2) re-instate calculation of shape parameter, s, and constants A and b

; *** Declare constants.
  Constants
; *** Declare the common block containing colour definitions
; *** and load the linear black & white colour table.
  COMMON Colours
  LOADCT, 0
; *** Set constants and switches.
  NDVIClip = 0.05	; NDVI values less than NDVIClip will be excluded
  MaxCWgt = 0.8		; Maximum cumulative footprint weight
  Pause = 'N'
  TestE = -9999.	; 530.230
  TestN = -9999.	; 6121.190
; *** Read the definitions file.
  GetGen, GenFile, Defn, Runs
; *** Open the NDVI file and read the file contents.
  NDVI = FLTARR(5202,2002)
  InLun = GetLun()
  NDVIFile = 'e:\oasis95\landsat\data\ndvi.dat'
  OPENR, InLun, NDVIFile, /BINARY, /NOAUTOMODE
  READU, InLun, NDVI
  FREE_LUN, InLun
; *** Set some parameters for either grid or transect processing.
  CASE STRUPCASE(Defn.Type) OF
   'GRID': BEGIN
     TorG = 'G'
     SubFile = 'D:\OASIS95\FOOTPRINT\NDVIGRD.GRD'
     BLNFile = 'D:\OASIS95\FOOTPRINT\FTPNGRD.BLN'
     WTitle = 'Grid'
     CE = 477.0				; Centre easting, m
     CN = 6109.0			; Centre northing, m
     IWm = 12.0				; Image width, m
     BLE = CE - IWm/2.		; Bottom left easting, m
     BLN = CN - IWm/2.		; Bottom left northing, m
     TRE = CE + IWm/2.		; Top right easting, m
     TRN = CN + IWm/2.		; Top right northing, m
     BLCol = FIX((BLE -  420.006)*40.00338 + 0.5)
     BLRow = 2001 - FIX((BLN - 6079.975)*40.01440 + 0.5)
     TRCol = FIX((TRE -  420.006)*40.00338 + 0.5)
     TRRow = 2001 - FIX((TRN - 6079.975)*40.01440 + 0.5)
     NCol = TRCol - BLCol + 1	; Number of columns
     NRow = BLRow - TRRow + 1	; Number of rows
     NDVIsub = NDVI(BLCol:TRCol,TRRow:BLRow)
     z0 = 0.03				; Roughness length, m
     Space = 0.5			; Space between weighted NDVI estimates, km
    END
   'TRAN': BEGIN
     TorG = 'T'
     SubFile = 'D:\OASIS95\FOOTPRINT\NDVITRN.GRD'
     BLNFile = 'D:\OASIS95\FOOTPRINT\FTPNTRN.BLN'
     TmpFile = 'D:\OASIS95\FOOTPRINT\FTPTMP.DAT
     WTitle = 'Whole Transect'
     BLE = 420.0
     TRE = 550.0
     BLN = 6080.0
     TRN = 6130.0
     NCol = 520
     NRow = 200
     NDVIsub = CONGRID(NDVI, NCol, NRow)
     z0 = 0.03
     Space = 0.25			; Space between weighted NDVI estimates, km
    END
  ENDCASE
; *** Write a SURFER .GRD file of the sub-area NDVI.
  WriteGRD, SubFile, NDVIsub, [BLE,TRE], [BLN,TRN], /BINARY
; *** Start of the plotting loop, we return here if the graphics device
; *** has been changed to produce a hard copy output.
PlotLoop:
  LMar = 10.*!D.X_CH_SIZE
  RMar = LMar/2.
  BMar = 5.*!D.Y_CH_SIZE
  TMar = BMar/2.
  Result = SIZE(NDVIsub)
  IXSize = Result[1]
  IYSize = Result[2]
  CASE !D.NAME OF
   'WIN': BEGIN
     WXSize = IXSize + LMar + RMar
     WYSize = IYSize + BMar + TMar
     WINDOW, 1, TITLE='NDVI : Overlapping', XSIZE=WXSize, YSIZE=WYSize
     X0 = LMar/WXSize
     Y0 = BMar/WYSize
     X1 = (IXSize+LMar)/WXSize
     Y1 = (IYSize+BMar)/WYSize
     Pen1 = 235
    END
   'CGM': BEGIN
     WXSize = !D.X_SIZE
     WYSize = !D.Y_SIZE
     X0 = LMar/WXSize
     Y0 = BMar/WYSize
     X1 = (WXSize-RMar)/WXSize
     Y1 = X1*IYSize/IXSize
     Pen1 = 0
    END
   ELSE: STOP, 'Unsupported graphics output device'
  ENDCASE
  PLOT, [BLE,TRE], [BLN,TRN], $
        XSTYLE=1, YSTYLE=1, /NODATA, $
        XTITLE='Easting (km)', YTITLE='Northing (km)', $
        POS=[X0,Y0,X1,Y1], /NORMAL, COLOR=Pen1
  TVSCL, NDVIsub, X0, Y0, XSIZE=X1-X0, YSIZE=Y1-Y0, /NORMAL, ORDER=1
; *** Open the output file for the footprint lines.  This will be a .BLN file
; *** for use with SURFER.
  BLNLun = GetLun()
  OPENW, BLNLun, BLNFile
  TmpLun = GetLun()
  OPENW, TmpLun, TmpFile

; *** Loop over the runs.
  FOR i = 0, Runs.No-1 DO BEGIN
; *** Get the input data file names.
   DatAFile = Defn.Stat + TorG + 'FXA' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
   DatBFile = Defn.Stat + TorG + 'FXB' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
   DatEFile = Defn.Stat + TorG + 'FXE' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
; *** Read the first input data file, this contains the mean values in both
; *** overlapping and non-overlapping blocks.
   GetFC, DatAFile, Data
; *** Get the required series and clear the input data array.
   GetSer, Data, Ind,  'Ind',  0, 0, 1
   GetSer, Data, ACE,  'AMGE', 0, 0, 1
   GetSer, Data, ACN,  'AMGN', 0, 0, 1
   GetSer, Data, Ta,   'Ta',   0, 0, 1
   GetSer, Data, p,    'p',    0, 0, 1
   GetSer, Data, WD,   'D',    0, 0, 1
   GetSer, Data, zAGL, 'zAGL', 0, 0, 1
   Data = 0.
   MinE = MIN(ACE[WHERE(Ind LE 500)])
   MaxE = MAX(ACE[WHERE(Ind LE 500)])
; *** Read the second input data file, this contains the fluxes.
   GetFC, DatBFile, Data
; *** Get the required series and clear the input data array.
   GetSer, Data, Us, 'Us', 0, 0, 1
   GetSer, Data, H,  'Hr', 0, 0, 1
   Data = 0.
; *** Read the third input data file, this contains the start and end locations
; *** of the overlapping and non-overlapping blocks.
   GetFC, DatEFile, Data
; *** Get the required series and clear the input data array.
   GetSer, Data, SE, 'SAMGE', 0, 0, 1
   GetSer, Data, EE, 'EAMGE', 0, 0, 1
   GetSer, Data, SN, 'SAMGN', 0, 0, 1
   GetSer, Data, EN, 'EAMGN', 0, 0, 1
   Data = 0.
; *** Get the number of elements.
   NEle = N_ELEMENTS(Ind)
; *** Set weakly stable conditions to weakly unstable.
   TInd = WHERE(H LT -50, NInd)
   IF (NInd NE 0) THEN BEGIN
    PRINT,'Set ',NInd,' instances of H to -9999 out of ',NEle
    H[TInd] = -9999.0
    IF Pause EQ 'Y' THEN Pause
   ENDIF
   TInd = WHERE(H GE -50 AND H LT 10, NInd)
   IF (NInd NE 0) THEN BEGIN
    PRINT,'Set ',NInd,' instances of H to 10 W/m2 out of ',NEle
    H[TInd] = 10.0
    IF Pause EQ 'Y' THEN Pause
   ENDIF
; *** Calculate some derived quantities.
   L = MOLen(Ta, p , Us, H)
; *** Now we loop over the aircraft locations in the input data file
; *** and for each location we:
; ***  - calculate the footprint weights at a range of
; ***    distances upwind of the aircraft
; ***  - convert the distances from the aircraft to
; ***    indices for the NDVI array
; ***  - sum the weighted NDVI over these indices
; ***  - sum the weights
; ***  - get the average weighted NDVI from the sum
; ***    of the weighted NDVI divided by the sum of
; ***    the weights
   WgtNDVI = MAKE_ARRAY(NEle,/FLOAT,VALUE=-9999.0)
   WgtNDVI_0 = MAKE_ARRAY(NEle,/FLOAT,VALUE=-9999.0)
   IF TorG EQ 'G' THEN BEGIN
    H[WHERE(Ind EQ 809)] = -9999					; Clip H to suppress processing
    H[WHERE(Ind EQ 909)] = -9999					; of whole grid leg values
   ENDIF
   FOR j = 0, NEle-1 DO BEGIN						; Loop over aircraft locations
    PrintTmp = 0
    IF ACE[j] EQ TestE AND ACN[j] EQ TestN THEN PrintTmp = 1
    IF (FIX(H[j]) NE -9999) THEN BEGIN				;
     FPN = CWIFootprint(zAGL[j], z0, L[j], Us[j], MaxCWgt)	; Get the CWI source-area weights
     dX = Centreddifference(FPN.Distance,INDGEN(N_ELEMENTS(FPN.Distance)))
     RSWeights = RunSum(FPN.Weights*dX)				; Running sum of CWI source-area weights
     EDist = SE[j] - EE[j]							; East distance from start to finish of averaging block
     NDist = SN[j] - EN[j]							; North distance from start to finish of averaging block
     Dist = SQRT(EDist^2 + NDist^2)					; Averaging length
     Num = FIX(Dist/Space)							; Number of locations along averaging block
     IF (Num MOD 2) EQ 0 THEN Num = Num + 1			; Make sure Num is odd so discrete central point exists
     TmpWgtNDVI = MAKE_ARRAY(Num,/FLOAT)
     ESpace = EDist/FLOAT(Num)
     NSpace = NDist/FLOAT(Num)
     ECmpt = 0.001*FPN.Distance*SIN(!DTOR*WD[j])	; FPN.Distance in m, ACE & FTE in km
     NCmpt = 0.001*FPN.Distance*COS(!DTOR*WD[j])	; FPN.Distance in m, ACN & FTN in km
     IF PrintTmp EQ 1 THEN BEGIN
      PRINTF, TmpLun, ACE[j], ACN[j], WD[j], FORMAT='(2F9.3,I8)'
      PRINTF, TmpLun, EDist, NDist, Dist, ESpace, NSpace, Num, FORMAT='(5F9.3,I8)'
     ENDIF
     FOR n = 0, Num-1 DO BEGIN						; Loop over locations along averaging block
      FTE = (ACE[j]-(n-FIX(Num/2))*ESpace) + ECmpt
      FTN = (ACN[j]-(n-FIX(Num/2))*NSpace) + NCmpt
      FTCol = FIX((FTE - 420.006)*40.00338 + 0.5)
      FTRow = 2001 - FIX((FTN - 6079.975)*40.01440 + 0.5)
      Ind1 = WHERE(RSWeights LE MaxCWgt,NInd1)
;      IF NInd1 NE 0 AND FTE[0] GE MinE THEN BEGIN
      IF NInd1 NE 0 THEN BEGIN
       TmpWgts = FPN.Weights[Ind1]*dX[Ind1]
       TmpNDVI = NDVI[FTCol[Ind1],FTRow[Ind1]]
       Ind2 = WHERE(TmpNDVI GE NDVIClip, NInd2)
       IF NInd2 NE 0 THEN BEGIN
        TmpWgtNDVI[n] = TOTAL(TmpWgts[Ind2]*TmpNDVI[Ind2])/TOTAL(TmpWgts[Ind2])
        ID = '"'+CleanString(Runs.ACDay[i])+' '+CleanString(Runs.ID[i])+' '+CleanString(STRING(Ind[j],FORMAT='(I4)'))+'"'
        PRINTF, BLNLun, 2, 1, ID, FORMAT='(2I4,1X,A)'
        PRINTF, BLNLun, FTE[Ind2[0]], FTN[Ind2[0]], FORMAT='(2F8.2)'
        PRINTF, BLNLun, FTE[Ind2[NInd2-1]], FTN[Ind2[NInd2-1]], FORMAT='(2F8.2)'
        IF PrintTmp EQ 1 THEN BEGIN
         FOR p = 0, NInd2-1 DO BEGIN
          PRINTF, TmpLun, FTE[p],FTN[p],TmpNDVI[p],TmpWgts[p], FORMAT='(2F9.3,F8.3,E12.3)'
         ENDFOR						; End of loop over print to temporary file
        ENDIF
        IF n EQ (Num-1)/2 THEN BEGIN
         WgtNDVI_0[j] = TmpWgtNDVI[n]
         IF Ind[j] LT 500 THEN BEGIN
          WSET, 1
          OPLOT, FTE[Ind2], FTN[Ind2], THICK=2, COLOR=black
         ENDIF
        ENDIF
       ENDIF ELSE BEGIN
        TmpWgtNDVI[n] = -9999.0
        WgtNDVI_0[j] = -9999.0
       ENDELSE
      ENDIF ELSE BEGIN
       TmpWgtNDVI[n] = -9999.0
       WgtNDVI_0[j] = -9999.0
      ENDELSE
     ENDFOR							; End of loop over locations along averaging block
     WgtNDVI[j] = MEAN(TmpWgtNDVI[WHERE(FIX(TmpWgtNDVI) NE -9999)])
    ENDIF ELSE BEGIN
     WgtNDVI[j] = -9999.0
     WgtNDVI_0[j] = -9999.0
    ENDELSE
   ENDFOR							; End of loop over values in input files
   IF TorG EQ 'G' THEN BEGIN
    WgtNDVI[WHERE(Ind EQ 809)] = MEAN(WgtNDVI[WHERE(Ind GE 801 AND Ind LE 806)])
    WgtNDVI[WHERE(Ind EQ 909)] = MEAN(WgtNDVI[WHERE(Ind GE 901 AND Ind LE 906)])
    WgtNDVI_0[WHERE(Ind EQ 809)] = MEAN(WgtNDVI_0[WHERE(Ind GE 801 AND Ind LE 806)])
    WgtNDVI_0[WHERE(Ind EQ 909)] = MEAN(WgtNDVI_0[WHERE(Ind GE 901 AND Ind LE 906)])
   ENDIF
   OutFile = Defn.Stat + 'NDVI' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
   FCHeader = 'Weighted NDVI for ' + Runs.ACDay[i] + Runs.ID[i]
   PutSer, Data, Ind, 'Ind'
   PutSer, Data, ACE, 'AMGE'
   PutSer, Data, ACN, 'AMGN'
   PutSer, Data, WgtNDVI, 'wNDVI'
   PutSer, Data, WgtNDVI_0, 'wNDVI0'
   PutFC, OutFile, Data, FCHeader, '(I4,4F10.3)'

  ENDFOR							; End of loop over runs
; *** Close the .BLN file and free the logical unit number.
  FREE_LUN, BLNLun
  FREE_LUN, TmpLun

; *** Check to see if we want to save the plot.
  Result = GraphicsOutput()
  IF (Result EQ 1) THEN GOTO, PlotLoop

Finish:
END
