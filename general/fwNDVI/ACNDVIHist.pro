PRO ACNDVIHist
; AUTHOR: PRI
; DATE: 11/10/2003
; PURPOSE:
;  Get a histogram of NDVI values for an image.
; INPUTS:
; OUTPUTS:
; METHOD:
; USES:

DataPath = 'D:\THESIS\CHAPTER8\FIG8.12\'
DataName = 'GRD020A.DAT'
DataFile = DataPath+DataName
HistFile = DataPath+'ACNDVIHist.DAT'

   BinSize = 0.02
   MinValue = 0.0
   MaxValue = 1.0

   GetFC, DataFile, Data, Skip=0
; *** Get the required series and clear the input data array.
   GetSer, Data, NDVI,  'NDVI',  0, 0, 1
   Data = 0

   Result = HISTOGRAM(NDVI,BINSIZE=BinSize,MIN=MinValue,MAX=MaxValue)
   BinMidPoints = BinSize*(FINDGEN(N_ELEMENTS(Result)) + 1.0) - BinSize/2.0
   PerCent = 100.*Result/TOTAL(Result)

   BAR_PLOT,Result

   FCHeader = 'Histogram of SAW NDVI for grid'
   PutSer, Data, BinMidPoints, 'Mid'
   PutSer, Data, Result, 'Num'
   PutSer, Data, PerCent, '%'
   PutFC, HistFile, Data, FCHeader, '(F8.2,I8,F8.2)'

END