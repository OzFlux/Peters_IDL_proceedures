PRO NDVI2SfcP2Fluxes
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
  NDVIFile = 'E:\OASIS95\LANDSAT\DATA\NDVI.DAT'
  MetFile = 'D:\OASIS95\GROUND\BROWN\AVG60.CSV'
  OutFile = 'D:\OASIS95\REGIONALFLUXES\NDVI\REGFLUX.DAT'
  NDVIMin1 = 0.53	; Urana pasture, used for Fe, Fh and regional Fc
  NDVIMin2 = 0.67	; Browning pasture, used for Fc obs comparison
  cq = 0.6
  Lai = 2.3
  S50 = 100
  D0 = 0.005
  tau = EXP(-cq*Lai)
; *** Put the linear regression coefficients into vectors, first
; *** element is the offset, second is the slope.  Values come from
; *** D:\THESIS\CHAPTER6\FIG6.15\TRANSECTAVERAGERATIOS.XLS.
  EFCoeffs = [-0.69,1.71]
  GsxCoeffs = [-0.0336,0.0570]
  WueCoeffs = [22.3,-36.0]
  BLE = 420.0
  TRE = 550.0
  BLN = 6080.0
  TRN = 6130.0
  NCol = 520
  NRow = 200
; *** Open the NDVI file and read the file contents.
  NDVI = FLTARR(5202,2002)
  InLun = GetLun()
  OPENR, InLun, NDVIFile, /BINARY, /NOAUTOMODE
  READU, InLun, NDVI
  FREE_LUN, InLun
; *** Resize the NDVI image by omitting the outside rows and columns,
; *** this means we can, if desired, use REBIN to average the NDVI array.
  NDVI = NDVI[1:5200,1:2000]
  NDVI = CONGRID(NDVI, NCol, NRow)
; *** Identify values of NDVI outside the range used for the regression.
  Idx1 = WHERE(NDVI GE NDVIMin1, NIdx1)
  Idx2 = WHERE(NDVI GE NDVIMin2, NIdx2)
; *** Calculate the evaporative fraction, the maximum stomatal conductance
; *** and the water-use efficiency.
  EF = EFCoeffs[1]*NDVI + EFCoeffs[0]
  Gsx = GsxCoeffs[1]*NDVI + GsxCoeffs[0]
  Wue = WueCoeffs[1]*NDVI + WueCoeffs[0]
; *** Read in the meteorological data.
  GetFC, MetFile, Data
; *** Get the required series and clear the input data array.
  GetSer, Data, Day, 'Day', 0, 0, 1
  GetSer, Data, Hour, 'Hour', 0, 0, 1
  GetSer, Data, S, 'Sin', 0, 0, 1
  GetSer, Data, A, 'A', 0, 0, 1
  GetSer, Data, D, 'D', 0, 0, 1
  GetSer, Data, Ga, 'Ga', 0, 0, 1
  GetSer, Data, Gi, 'Gi', 0, 0, 1
  GetSer, Data, eps, 'Eps', 0, 0, 1
  Data = 0.
  NEle = N_ELEMENTS(Day)
  LEFromEF = MAKE_ARRAY(NEle)
  HFromEF = MAKE_ARRAY(NEle)
  FcFromEF = MAKE_ARRAY(NEle)
; *** Calculate LE, H and Fc using the evaporative fraction.
  FOR i = 0, NEle-1 DO BEGIN
   LEFromEF[i] = MEAN(A[i]*EF[Idx1])
   HFromEF[i] = A[i] - LEFromEF[i]
   FcFromEF[i] = MEAN(Wue[Idx1]*LEFromEF[i])/2453.6
  ENDFOR
  EF = 0.
  LEFromGsx = MAKE_ARRAY(NEle)
  HFromGsx = MAKE_ARRAY(NEle)
  FcFromGsx = MAKE_ARRAY(NEle)
; *** Calculate LE, H and Fc using the maximum stomatal conductance.
  FOR i = 0, NEle-1 DO BEGIN
   GcFromGsx = (Gsx[Idx]/cq)*ALOG((S[i]+S50)/(S[i]*tau+S50))/(1.+D[i]/D0)
   GsFromGc = GcFromGsx*(1.+(Ga[i]/(eps[i]*Gi[i]))+(tau*Ga[i]/((eps[i]+1.)*GcFromGsx)))/(1.+(Ga[i]/(eps[i]*Gi[i]))-tau)
   LEFromGsx[i] = MEAN(A[i]*((eps[i]+Ga[i]/Gi[i])/(eps[i]+1.+Ga[i]/GsFromGc)))
   HFromGsx[i] = A[i] - LEFromGsx[i]
   FcFromGsx[i] = MEAN((0.5*Hour[i] + (Wue[Idx] - 0.5*12.5))*LEFromGsx[i])/2453.6
  ENDFOR
  Gsx = 0.
  GcFromGsx = 0.
  GsFromGc = 0.
; *** Write the data out to file.
  PutSer, Data, Day, 'Day'
  PutSer, Data, Hour, 'Hour'
  PutSer, Data, LEFromEF, 'LE(EF)'
  PutSer, Data, HFromEF, 'H(EF)'
  PutSer, Data, FcFromEF, 'Fc(EF)'
  PutSer, Data, LEFromGsx, 'LE(gsx)'
  PutSer, Data, HFromGsx, 'H(gsx)'
  PutSer, Data, FcFromGsx, 'Fc(gsx)'
  FCHeader = 'Fluxes for OASIS domain'
  PutFC, OutFile, Data, FCHeader, '(2I4,2I8,F8.2,2I8,F8.2)'

Finish:
END
