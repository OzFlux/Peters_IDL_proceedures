PRO fwNDVIgb

; Declare constants.
  Constants

  Site = 'WW'

; Open the NDVI file and read the file contents.
  NDVI = FLTARR(5202,2002)
  InLun = GetLun()
  NDVIFile = 'e:\oasis95\landsat\data\ndvi.dat'
  OPENR, InLun, NDVIFile, /BINARY, /NOAUTOMODE
  READU, InLun, NDVI
  FREE_LUN, InLun
; Set the site specific parameters.
  CASE Site OF
   'WT': BEGIN
     SE = 530.831		; Site easting, km
     SN = 6120.550		; Site northing, km
     hc = 1.1			; Canopy height, m
     zm = 2.84			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNWT.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\WTSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\WAGGA\TRIT30.CSV'
     OutFile = 'D:\OASIS95\GROUND\WAGGA\NDVIWT.DAT'
    END
   'WP': BEGIN
     SE = 530.506		; Site easting, km
     SN = 6120.550		; Site northing, km
     hc = 0.3			; Canopy height, m
     zm = 2.2			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNWP.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\WPSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\WAGGA\PAST30.CSV'
     OutFile = 'D:\OASIS95\GROUND\WAGGA\NDVIWP.DAT'
    END
   'BO': BEGIN
     SE = 479.935		; Site easting, km
     SN = 6108.058		; Site northing, km
     hc = 0.9			; Canopy height, m
     zm = 4.05			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNBO.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\BOSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\BROWN\OATS15.CSV'
     OutFile = 'D:\OASIS95\GROUND\BROWN\NDVIBO.DAT'
    END
   'BP': BEGIN
     SE = 478.372		; Site easting, km
     SN = 6108.505		; Site northing, km
     hc = 0.2			; Canopy height, m
     zm = 3.7			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNBP.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\BPSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\BROWN\PAST15.CSV'
     OutFile = 'D:\OASIS95\GROUND\BROWN\NDVIBP.DAT'
    END
   'CC': BEGIN
     SE = 480.895		; Site easting, km
     SN = 6108.853		; Site northing, km
     hc = 1.6			; Canopy height, m
     zm = 4.0			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNCC.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\CCSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\BROWN\CANO20.CSV'
     OutFile = 'D:\OASIS95\GROUND\BROWN\NDVICC.DAT'
    END
   'WW': BEGIN
     SE = 475.354		; Site easting, km
     SN = 6104.928		; Site northing, km
     hc = 1.15			; Canopy height, m
     zm = 4.5			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNWW.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\WWSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\WATTLES\WHEA30.CSV'
     OutFile = 'D:\OASIS95\GROUND\WATTLES\NDVIWW.DAT'
    END
   'UW': BEGIN
     SE = 447.281		; Site easting, km
     SN = 6098.038		; Site northing, km
     hc = 0.8			; Canopy height, m
     zm = 2.5			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNUW.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\UWSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\URANA\WHEA15.CSV'
     OutFile = 'D:\OASIS95\GROUND\URANA\NDVIUW.DAT'
    END
   'UP': BEGIN
     SE = 448.248		; Site easting, km
     SN = 6098.573		; Site northing, km
     hc = 0.1			; Canopy height, m
     zm = 2.5			; Measurement height, m
     BLNFile = 'E:\OASIS95\LANDSAT\BLNFILES\FTPNUP.BLN'
     SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\UPSUB.GRD'
     DatFile = 'D:\OASIS95\GROUND\URANA\PAST15.CSV'
     OutFile = 'D:\OASIS95\GROUND\URANA\NDVIUP.DAT'
    END
  ENDCASE
  d   = 0.67*hc			; Displacement height, m
  z0  = 0.1*hc			; Roughness length for momentum, m
  z0T = z0/5.			; Roughness length for heat, m
; Set the image width, calculate the image boundaries and select the
; subset of the image to be displayed.
  IWm = 3.0				; Image width, km
  IWp = IWm*1000./25.	; Image width, pixels
  BLE = SE - IWm/2.		; Bottom left easting, km
  BLN = SN - IWm/2.		; Bottom left northing, km
  TRE = SE + IWm/2.		; Top right easting, km
  TRN = SN + IWm/2.		; Top right northing, km
  BLCol = FIX((BLE -  420.006)*40.00338 + 0.5)
  BLRow = 2001 - FIX((BLN - 6079.975)*40.01440 + 0.5)
  TRCol = FIX((TRE -  420.006)*40.00338 + 0.5)
  TRRow = 2001 - FIX((TRN - 6079.975)*40.01440 + 0.5)
  NCol = TRCol - BLCol + 1
  NRow = BLRow - TRRow + 1
  NDVIsub = NDVI(BLCol:TRCol,TRRow:BLRow)
; Write the image subset to a SURFER .GRD file.
  WriteGRD, SubFile, NDVIsub, [BLE,TRE], [BLN,TRN], /BINARY
; Start of the plotting loop, we return here if the graphics device
; has been changed to produce a hard copy output.
PlotLoop:
  LMar = 10.*!D.X_CH_SIZE
  RMar = LMar/2.
  BMar = 5.*!D.Y_CH_SIZE
  TMar = BMar/2.
  CASE !D.NAME OF
   'WIN': BEGIN
     Result = Get_Screen_Size()
     WXSize = Result[0]/2.
     WYSize = ((WXSize - LMar - RMar)*NRow/NCol) + BMar + TMar
     NDVIsub = CONGRID(NDVIsub,WXSize-LMar-RMar,WYSize-BMar-TMar,/INTERP)
     WINDOW, 1, TITLE='NDVI', XSIZE=WXSize, YSIZE=WYSize
     Pen1 = 235
    END
   'CGM': BEGIN
     WXSize = !D.X_SIZE
     WYSize = !D.Y_SIZE
     Pen1 = 0
    END
   ELSE: STOP, 'Unsupported graphics output device'
  ENDCASE
  X0 = LMar/WXSize
  Y0 = BMar/WYSize
  X1 = (WXSize - RMar)/WXSize
  Y1 = (BMar + (WXSize - LMar - RMar)*NRow/NCol)/WYSize
  PLOT, [BLE,TRE], [BLN,TRN], $
        XSTYLE=1, YSTYLE=1, /NODATA, $
        XTITLE='Easting (km)', YTITLE='Northing (km)', $
        POS=[X0,Y0,X1,Y1], /NORMAL, COLOR=Pen1
  TVSCL, NDVIsub, X0, Y0, XSIZE=X1-X0, YSIZE=Y1-Y0, /NORMAL, ORDER=1
  IF (!D.NAME EQ 'WIN') THEN PAUSE

; Open a file for the footprint lines.
  BLNLun = GetLun()
  OPENW, BLNLun, BLNFile

; Read the ground based data file.
  GetFC, DatFile, Data
; Get the required series and clear the input data array.
  GetSer, Data, Day, 'Day', 0, 0, 1
  GetSer, Data, Hour, 'Hour', 0, 0, 1
  GetSer, Data, Minute, 'Minute', 0, 0, 1
  GetSer, Data, Ta, 'Ta', 0, 0, 1
  GetSer, Data, p,  'p', 0, 0, 1
  GetSer, Data, WD, 'WD', 0, 0, 1
  GetSer, Data, Us, 'ustar', 0, 0, 1
  GetSer, Data, H,  'H', 0, 0, 1
  Data = 0.
; Get the number of elements.
   NEle = N_ELEMENTS(H)
; Calculate some derived quantities.
   L = MOLen(Ta, p, Us, H)
; Now we loop over the data in the input data file and for each
; valid data point we:
;  - calculate the footprint weights at a range of
;    distances upwind of the tower
;  - convert the distances from the tower to
;    indices for the NDVI array
;  - sum the weighted NDVI over these indices
;  - sum the weights
;  - get the average weighted NDVI from the sum
;    of the weighted NDVI divided by the sum of
;    the weights
   XMax = 2000.
   NStep = 80.
   WgtNDVI = MAKE_ARRAY(NEle, /FLOAT)
   DataOK = MAKE_ARRAY(NEle, /FLOAT, VALUE=0)
   OKPtr = WHERE(H GE 5. AND L NE -9999. AND WD NE -9999.)
   PRINT, 'Number of OK data points is '+CleanString(STRING(N_ELEMENTS(OKPtr)))
   DataOK[OKPtr] = 1
   FOR j = 0, NEle-1 DO BEGIN
    IF DataOK[j] EQ 1 THEN BEGIN
     FPN = FootPrint(zm, L[j], z0, XMax, NStep)
     RSWeights = RunSum(FPN.Weights)/TOTAL(FPN.Weights)
     FTE = SE + 0.001*FPN.Distance*SIN(!DTOR*WD[j])	; FPN.Distance in m, SE & FTE in km
     FTN = SN + 0.001*FPN.Distance*COS(!DTOR*WD[j])	; FPN.Distance in m, SN & FTN in km
     FTCol = FIX((FTE - 420.006)*40.00338 + 0.5)
     FTRow = 2001 - FIX((FTN - 6079.975)*40.01440 + 0.5)
     Ptr = WHERE(RSWeights LE 0.90,NPtr)
     IF NPtr NE 0 THEN BEGIN
      WgtNDVI[j] = TOTAL(FPN.Weights[Ptr]*NDVI[FTCol[Ptr],FTRow[Ptr]])/TOTAL(FPN.Weights[Ptr])
      OPLOT, FTE[Ptr], FTN[Ptr], THICK=2, COLOR=Pen1
      PRINTF, BLNLun, 2, 1, FORMAT='(2I2)'
      PRINTF, BLNLun, FTE[Ptr[0]], FTN[Ptr[0]], FORMAT='(2F8.2)'
      PRINTF, BLNLun, FTE[Ptr[NPtr-1]], FTN[Ptr[NPtr-1]], FORMAT='(2F8.2)'
     ENDIF
    ENDIF
   ENDFOR

   ODay = [Day[OKPtr],98,99]
   OHour = [Hour[OKPtr],98,99]
   OMinute = [Minute[OKPtr],98,99]
   OTa = [Ta[OKPtr],MEAN(Ta[OKPtr]),STDDEV(Ta[OKPtr])]
   Op = [p[OKPtr],MEAN(p[OKPtr]),STDDEV(p[OKPtr])]
   OWD = [WD[OKPtr],MEAN(WD[OKPtr]),STDDEV(WD[OKPtr])]
   OUs = [Us[OKPtr],MEAN(Us[OKPtr]),STDDEV(Us[OKPtr])]
   OH = [H[OKPtr],MEAN(H[OKPtr]),STDDEV(H[OKPtr])]
   OL = [L[OKPtr],MEAN(L[OKPtr]),STDDEV(L[OKPtr])]
   OWgtNDVI = [WgtNDVI[OKPtr],MEAN(WgtNDVI[OKPtr]),STDDEV(WgtNDVI[OKPtr])]
   PutSer, Data, ODay, 'Day'
   PutSer, Data, OHour, 'Hr'
   PutSer, Data, OMinute, 'Min'
   PutSer, Data, OTa, 'Ta'
   PutSer, Data, Op, 'p'
   PutSer, Data, OWD, 'WD'
   PutSer, Data, OUs, 'Us'
   PutSer, Data, OH, 'H'
   PutSer, Data, OL, 'L'
   PutSer, Data, OWgtNDVI, 'wNDVI'
   FCHeader = 'Weighted NDVI for ' + Site
   PutFC, OutFile, Data, FCHeader, '(3I4,2F8.1,I8,F8.2,I8,F10.2,F8.2)'

; Close the .BLN file and free the logical unit number.
  FREE_LUN, BLNLun

; Check to see if we want to save the plot.
  Result = GraphicsOutput()
  IF (Result EQ 1) THEN GOTO, PlotLoop

Finish:

END
