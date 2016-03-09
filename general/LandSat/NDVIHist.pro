PRO NDVIHist
; AUTHOR: PRI
; DATE: 11/10/2003
; PURPOSE:
;  Get a histogram of NDVI values for an image.
; INPUTS:
; OUTPUTS:
; METHOD:
; USES:

DataPath = 'E:\OASIS95\LANDSAT\DATA\'
DataName = 'NDVI.DAT'
DataFile = DataPath+DataName
HistFile = DataPath+'NDVIHISTWAGGA.DAT'
GridFile = DataPath+'NDVISUB.GRD'

BinSize = 0.02
MinValue = 0.0
MaxValue = 1.0
WorG = 'G'
CE = 530.65				; Centre easting, km
CN = 6120.55			; Centre northing, km
IWm = 10.0				; Image width, km
BLE = CE - IWm/2.		; Bottom left easting, km
BLN = CN - IWm/2.		; Bottom left northing, km
TRE = CE + IWm/2.		; Top right easting, km
TRN = CN + IWm/2.		; Top right northing, km
BLCol = FIX((BLE -  420.006)*40.00338 + 0.5)
BLRow = 2001 - FIX((BLN - 6079.975)*40.01440 + 0.5)
TRCol = FIX((TRE -  420.006)*40.00338 + 0.5)
TRRow = 2001 - FIX((TRN - 6079.975)*40.01440 + 0.5)
NCol = TRCol - BLCol + 1	; Number of columns
NRow = BLRow - TRRow + 1	; Number of rows

InLun = GetLun()
OPENR, InLun, DataFile, /BINARY, /NOAUTOMODE
NDVI = ASSOC(InLun, FLTARR(5202,2002,/NOZERO))

NDVISub = NDVI(0)
IF WorG EQ 'G' THEN NDVISub = NDVISub(BLCol:TRCol,TRRow:BLRow)

WriteGRD, GridFile, NDVISub, [BLE,TRE], [BLN,TRN], /BINARY

Result = HISTOGRAM(NDVISub,BINSIZE=BinSize,MIN=MinValue,MAX=MaxValue)
BinMidPoints = BinSize*(FINDGEN(N_ELEMENTS(Result)) + 1.0) - BinSize/2.0
PerCent = 100.*Result/TOTAL(Result)

BAR_PLOT,Result

FCHeader = 'Histogram of NDVI for OASIS domain'
PutSer, Data, BinMidPoints, 'Mid'
PutSer, Data, Result, 'Num'
PutSer, Data, PerCent, '%'
PutFC, HistFile, Data, FCHeader, '(F8.2,I8,F8.2)'

END