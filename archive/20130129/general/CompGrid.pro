PRO CompGrid

DataPath = 'D:\THESIS\CHAPTER8\FIG8.13\'
NDVIFileXYZ = DataPath+'NDVIGridXYZ.DAT'
NDVIFileGRD = DataPath+'NDVIGridMod.GRD'
EFFileXYZ = DataPath+'EFGridXYZ.DAT'
EFFileGRD = DataPath+'EFGridMod.GRD'
ConvFileGRD = DataPath+'ConvGrid.GRD'
; *** Read the first file.
   GetFC, NDVIFileXYZ, Data
   GetSer, Data, AMGE1, 'AMGE', 0, 0, 1
   GetSer, Data, AMGN1, 'AMGN', 0, 0, 1
   GetSer, Data, NDVI, 'NDVI', 0, 0, 1
; *** Read the second file.
   GetFC, EFFileXYZ, Data
   GetSer, Data, AMGE2, 'AMGE', 0, 0, 1
   GetSer, Data, AMGN2, 'AMGN', 0, 0, 1
   GetSer, Data, EF, 'EF', 0, 0, 1
; *** Check to make sure that both files have the same number of records.
   IF (N_ELEMENTS(AMGE1) NE N_ELEMENTS(AMGE2)) THEN $
    ErrorHandler,'CompGrid: Files have different number of records', 1
; *** Get the mean of each series.
   MnNDVI = MEAN(NDVI)
   MnEF = MEAN(EF)
; *** Now set the series to +1 when the value exceeds the mean and -1
; *** when the value is less than the mean.
   GEInd = WHERE(NDVI GE MnNDVI)
   LTInd = WHERE(NDVI LT MnNDVI)
   NDVI[GEInd] =  1.0
   NDVI[LTInd] = -1.0
   GEInd = WHERE(EF GE MnEF)
   LTInd = WHERE(EF LT MnEF)
   EF[GEInd] =  1.0
   EF[LTInd] = -1.0
; *** Get the convolution of the two modified grids.
   Conv = NDVI*EF
; *** Write the modified data to .GRD files.
   BLE = MIN(AMGE1)
   TRE = MAX(AMGE1)
   BLN = MIN(AMGN1)
   TRN = MAX(AMGN1)
   NDVI2d = REVERSE(REFORM(NDVI,101,101),2)
   EF2d = REVERSE(REFORM(EF,101,101),2)
   Conv2d = REVERSE(REFORM(Conv,101,101),2)
   WriteGRD, NDVIFileGRD, NDVI2d, [BLE,TRE], [BLN,TRN], 'F5.1'
   WriteGRD, EFFileGRD, EF2d, [BLE,TRE], [BLN,TRN], 'F5.1'
   WriteGRD, ConvFileGRD, Conv2d, [BLE,TRE], [BLN,TRN], 'F5.1'
   Result = WHERE(Conv2d GE 0.0,GTNum)
   Result = WHERE(Conv2d LT 0.0,LTNum)
   PRINT,GTNum,LTNum,N_ELEMENTS(Conv2d)
END