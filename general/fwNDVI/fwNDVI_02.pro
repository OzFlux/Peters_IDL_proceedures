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
; *** Read the definitions file.
  GetGen, GenFile, Defn, Runs

  NDVIClip = 0.3	; NDVI values less than NDVIClip will be excluded

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
     SubFile = 'D:\THESIS\CHAPTER7\NDVIGRD.GRD'
     BLNFile = 'D:\THESIS\CHAPTER7\FTPNGRD.BLN'
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
    END
   'TRAN': BEGIN
     TorG = 'T'
     SubFile = 'D:\THESIS\CHAPTER7\NDVITRN.GRD'
     BLNFile = 'D:\THESIS\CHAPTER7\FTPNTRN.BLN'
     WTitle = 'Whole Transect'
     BLE = 420.0
     TRE = 550.0
     BLN = 6080.0
     TRN = 6130.0
     NCol = 520
     NRow = 200
     NDVIsub = CONGRID(NDVI, NCol, NRow)
     z0 = 0.03
    END
  ENDCASE
; *** Write a SURFER .GRD file of the sub-area NDVI.
  WriteGRD, SubFile, NDVIsub, [BLE,TRE], [BLN,TRN], 'F6.3'
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
     WINDOW, 1, TITLE='NDVI', XSIZE=WXSize, YSIZE=WYSize
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
  PAUSE
; *** Open the output file for the footprint lines.  This will be a .BLN file
; *** for use with SURFER.
  BLNLun = GetLun()
  OPENW, BLNLun, BLNFile

; *** Loop over the runs.
  FOR i = 0, Runs.No-1 DO BEGIN
; Get the input data file names.
   DatAFile = Defn.Stat + TorG + 'FXA' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
   DatBFile = Defn.Stat + TorG + 'FXB' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
; Read the first input data file.
   GetFC, DatAFile, Data
; Get the required series and clear the input data array.
   GetSer, Data, Ind,  'Ind',  0, 0, 1
   GetSer, Data, ACE,  'AMGE', 0, 0, 1
   GetSer, Data, ACN,  'AMGN', 0, 0, 1
   GetSer, Data, Ta,   'Ta',   0, 0, 1
   GetSer, Data, p,    'p',    0, 0, 1
   GetSer, Data, WD,   'D',    0, 0, 1
   GetSer, Data, zAGL, 'zAGL', 0, 0, 1
   Data = 0.
; Read the second input data file.
   GetFC, DatBFile, Data
; Get the required series and clear the input data array.
   GetSer, Data, Us, 'Us', 0, 0, 1
   GetSer, Data, H,  'Hr', 0, 0, 1
   Data = 0.
; Get the number of elements.
   NEle = N_ELEMENTS(H)
; Calculate some derived quantities.
   L = MOLen(Ta, p, Us, H)
; Now we loop over the aircraft locations in the input data file
; and for each location we:
;  - calculate the footprint weights at a range of
;    distances upwind of the aircraft
;  - convert the distances from the aircraft to
;    indices for the NDVI array
;  - sum the weighted NDVI over these indices
;  - sum the weights
;  - get the average weighted NDVI from the sum
;    of the weighted NDVI divided by the sum of
;    the weights
   WgtNDVI = MAKE_ARRAY(NEle,/FLOAT)
   FOR j = 0, NEle-1 DO BEGIN
    IF (H[j] GT 10.0) THEN BEGIN
     FPN = XWindIntFPN(zAGL[j], z0, L[j], Us[j])
     RSWeights = RunSum(FPN.Weights)/TOTAL(FPN.Weights)
     FTE = ACE[j] + 0.001*FPN.Distance*SIN(!DTOR*WD[j])	; FPN.Distance in m, ACE & FTE in km
     FTN = ACN[j] + 0.001*FPN.Distance*COS(!DTOR*WD[j])	; FPN.Distance in m, ACN & FTN in km
     FTCol = FIX((FTE - 420.006)*40.00338 + 0.5)
     FTRow = 2001 - FIX((FTN - 6079.975)*40.01440 + 0.5)
     Ind1 = WHERE(RSWeights LE 0.90,NInd1)
     IF NInd1 NE 0 THEN BEGIN
      TmpWgts = FPN.Weights[Ind1]
      TmpNDVI = NDVI[FTCol[Ind1],FTRow[Ind1]]
      Ind2 = WHERE(TmpNDVI GE NDVIClip, NInd2)
      IF NInd2 NE 0 THEN BEGIN
       WgtNDVI[j] = TOTAL(TmpWgts[Ind2]*TmpNDVI[Ind2])/TOTAL(TmpWgts[Ind2])
       OPLOT, FTE[Ind2], FTN[Ind2], THICK=2, COLOR=black
       PRINTF, BLNLun, 2, 1, FORMAT='(2I2)'
       PRINTF, BLNLun, FTE[Ind2[0]], FTN[Ind2[0]], FORMAT='(2F8.2)'
       PRINTF, BLNLun, FTE[Ind2[NInd2-1]], FTN[Ind2[NInd2-1]], FORMAT='(2F8.2)'
      ENDIF ELSE BEGIN
       WgtNDVI[j] = -9999.0
      ENDELSE
     ENDIF ELSE BEGIN
      WgtNDVI[j] = -9999.0
     ENDELSE
    ENDIF ELSE BEGIN
     WgtNDVI[j] = -9999.0
    ENDELSE
   ENDFOR

   OutFile = Defn.Stat + 'NDVI' + Runs.ACDay[i] + Runs.ID[i] + '.DAT'
   FCHeader = 'Weighted NDVI for ' + Runs.ACDay[i] + Runs.ID[i]
   PutSer, Data, Ind, 'Ind'
   PutSer, Data, ACE, 'AMGE'
   PutSer, Data, ACN, 'AMGN'
   PutSer, Data, WgtNDVI, 'wNDVI'
   PutFC, OutFile, Data, FCHeader, '(I4,3F10.2)'

  ENDFOR
; Close the .BLN file and free the logical unit number.
  FREE_LUN, BLNLun

; Check to see if we want to save the plot.
  Result = GraphicsOutput()
  IF (Result EQ 1) THEN GOTO, PlotLoop

Finish:
END
