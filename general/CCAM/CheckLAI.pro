PRO CheckLAI
; PURPOSE
;  Procedure to check 1988 vegetation and LAI grids for consistency.
; INPUT
;  Input files are the 1988 vegetation type and LAI files.
; OUTPUT
; DESCRIPTION
; USES
;  ReadGRD
; AUTHOR
;  Peter Isaac
; DATE
;  29 January 2005

; *** Declare constants and type variables.
;  Months = ['January','February','March','April','May','June','July',$
;            'August','September','October','November','December']
  Months = ['January','February']
  LAIPath = 'E:\CCAM\Vegetation\LAI\1988'
  SPLon = [147.334,148.152,146.554]
  SPLat = [-35.059,-35.656,-19.883]
;  SPLon = [147.334]
;  SPLat = [-35.059]

; *** Get the vegetation file name and read the data.
  Title = 'Select the 1988 vegetation type file'
  Filter = '*.grd'
  Path = 'E:\CCAM\Vegetation\Type\1988'
  VEGFile1988 = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  ReadGRD, VEGFile1988, VEGMeta1988, VEG1988
  NCol = VEGMeta1988[0]
  NRow = VEGMeta1988[1]
  IndVEGB = WHERE(VEG1988 EQ 1.70141E+038, CntVEGB)
  IndVEGV = WHERE(VEG1988 NE 1.70141E+038, CntVEGV)
; *** Loop over the monthly LAI files.
  NMths = N_ELEMENTS(Months)
  FOR i = 0, NMths-1 DO BEGIN
   LAIFile1988 = LAIPath+'\'+Months[i]+'_M.grd'
   ReadGRD, LAIFile1988, LAIMeta1988, LAI1988
   Ind1 = WHERE((LAI1988 NE 1.70141E+038 AND VEG1988 EQ 1.70141E+038), Cnt1)
   Ind2 = WHERE((LAI1988 EQ 1.70141E+038 AND VEG1988 NE 1.70141E+038), Cnt2)
; *** Get the latitude and longitude of the inconsistent grid cells.
   Row1 = FIX(Ind1/NCol)
   Col1 = FIX(Ind1 - Row1*NCol)
   Row2 = FIX(Ind2/NCol)
   Col2 = FIX(Ind2 - Row2*NCol)
; *** Get the row and column number for the spot points.
   SPCol = (SPLon - VEGMeta1988[2])/VEGMeta1988[3]
   SPRow = (SPLat - VEGMeta1988[4])/VEGMeta1988[5]
; *** Plot the vegetation type and LAI data and then superimpose the inconsistent
; *** points.
   PlotVEG = CONGRID(VEG1988,NCol/2,NRow/2)
   PlotLAI = CONGRID(LAI1988,NCol/2,NRow/2)
   Index = WHERE(PlotVEG EQ 1.70141E+038, Count)
   IF Count NE 0 THEN PlotVEG[Index] = 0.0
   Index = WHERE(PlotLAI EQ 1.70141E+038, Count)
   IF Count NE 0 THEN PlotLAI[Index] = 0.0
   WINDOW, /FREE, TITLE=Months[i], XSIZE=860, YSIZE=350
   TVSCL, PlotVEG, 0
   PLOTS, Col1/2, Row1/2, /DEVICE, PSYM=1, SYMSIZE=1, THICK=1
   PLOTS, SPCol/2, SPRow/2, /DEVICE, PSYM=1, SYMSIZE=2, THICK=2
   TVSCL, PlotLAI, 1
   PLOTS, 430+Col2/2, Row2/2, /DEVICE, PSYM=1, SYMSIZE=1, THICK=1
   PLOTS, 430+SPCol/2, SPRow/2, /DEVICE, PSYM=1, SYMSIZE=2, THICK=2
  ENDFOR
Finish:
END