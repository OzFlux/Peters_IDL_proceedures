PRO NDVISub
; AUTHOR: PRI
; DATE: Unknown
; PURPOSE:
;  This procedure reads a file of NDVI data generated from a LandSat image
;  and selects a subsection of the image for output.
;  Graphics output is to the screen or a CGM file and the subsection NDVI
;  data is also written to a Surfer .GRD file.
; INPUTS:
; OUTPUTS:
; METHOD:
; USES:

  LOADCT,0
; *** Open the NDVI file and read the file contents.
  NDVI = FLTARR(5202,2002)
  InLun = GetLun()
  NDVIFile = 'e:\oasis95\landsat\data\ndvi.dat'
  OPENR, InLun, NDVIFile, /BINARY, /NOAUTOMODE
  READU, InLun, NDVI
  FREE_LUN, InLun

  SubFile = 'E:\OASIS95\LANDSAT\GRDFILES\NDVIBS.GRD'
  CE = 478.0				; Centre easting, km
  CN = 6107.0				; Centre northing, km
  IWm = 8.0				; Image width, km
  BLE = CE - IWm/2.			; Bottom left easting, km
  BLN = CN - IWm/2.			; Bottom left northing, km
  TRE = CE + IWm/2.			; Top right easting, km
  TRN = CN + IWm/2.			; Top right northing, km
  BLCol = FIX((BLE -  420.006)*40.00338 + 0.5)
  BLRow = 2001 - FIX((BLN - 6079.975)*40.01440 + 0.5)
  TRCol = FIX((TRE -  420.006)*40.00338 + 0.5)
  TRRow = 2001 - FIX((TRN - 6079.975)*40.01440 + 0.5)
  NCol = TRCol - BLCol + 1	; Number of columns
  NRow = BLRow - TRRow + 1	; Number of rows
  NDVIsub = NDVI(BLCol:TRCol,TRRow:BLRow)
; *** Write a SURFER .GRD file of the sub-area NDVI.
  WriteGRD, SubFile, NDVIsub, [BLE,TRE], [BLN,TRN], 'F6.3'

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
     X0 = LMar/WXSize
     Y0 = BMar/WYSize
     X1 = (WXSize-RMar)/WXSize
     Y1 = X1*IYSize/IXSize
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
  PAUSE

; Check to see if we want to save the plot.
  Result = GraphicsOutput()
  IF (Result EQ 1) THEN GOTO, PlotLoop

END
