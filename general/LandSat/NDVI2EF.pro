PRO NDVI2EF
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

; *** Declare constants.
  Constants
; *** Declare the common block containing colour definitions
; *** and load the linear black & white colour table.
  COMMON Colours
  LOADCT, 0
; *** Set constants and switches.
  NDVIDatFile = 'E:\OASIS95\LANDSAT\DATA\NDVI.DAT'
  NDVIGrdFile = 'E:\OASIS95\LANDSAT\GRDFILES\NDVI.GRD'
  EFGrdFile = 'E:\OASIS95\LANDSAT\GRDFILES\EF.GRD'
  WUGrdFile = 'E:\OASIS95\LANDSAT\GRDFILES\WU.GRD'
  BLE = 420.0
  TRE = 550.0
  BLN = 6080.0
  TRN = 6130.0
  NCol = 520
  NRow = 200
; *** Open the NDVI file and read the file contents.
  NDVI = FLTARR(5202,2002)
  InLun = GetLun()
  OPENR, InLun, NDVIDatFile, /BINARY, /NOAUTOMODE
  READU, InLun, NDVI
  FREE_LUN, InLun
; *** Resize the NDVI image by omitting the outside rows and columns,
; *** this means we can use REBIN to average the NDVI array.
  NDVI = NDVI[1:5200,1:2000]
  EF = 1.39*NDVI - 0.51
  WU = -32.77*NDVI + 20.47
;  NDVISubArea = CONGRID(NDVI, NCol, NRow)
;  EFSubArea = CONGRID(EF, NCol, NRow)
;  WUSubArea = CONGRID(WU, NCol, NRow)
  NDVISubArea = REBIN(NDVI, NCol, NRow)
  EFSubArea = REBIN(EF, NCol, NRow)
  WUSubArea = REBIN(WU, NCol, NRow)
; *** Write a SURFER .GRD file of the sub-area NDVI and EF
  WriteGRD, NDVIGrdFile, NDVISubArea, [BLE,TRE], [BLN,TRN], 'F6.3'
  WriteGRD, EFGrdFile, EFSubArea, [BLE,TRE], [BLN,TRN], 'F6.3'
  WriteGRD, WUGrdFile, WUSubArea, [BLE,TRE], [BLN,TRN], 'F6.3'
; *** Start of the plotting loop, we return here if the graphics device
; *** has been changed to produce a hard copy output.
PlotLoop:
  LMar = 10.*!D.X_CH_SIZE
  RMar = LMar/2.
  BMar = 5.*!D.Y_CH_SIZE
  TMar = BMar/2.
  Result = SIZE(NDVISubArea)
  IXSize = Result[1]
  IYSize = Result[2]
  CASE !D.NAME OF
   'WIN': BEGIN
     WXSize = IXSize + LMar + RMar
     WYSize = IYSize + BMar + TMar
     WINDOW, 1, TITLE='NDVI : OASIS95 Domain', XSIZE=WXSize, YSIZE=WYSize
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
  TVSCL, NDVISubArea, X0, Y0, XSIZE=X1-X0, YSIZE=Y1-Y0, /NORMAL, ORDER=1

; *** Check to see if we want to save the plot.
  Result = GraphicsOutput()
  IF (Result EQ 1) THEN GOTO, PlotLoop

Finish:
END
