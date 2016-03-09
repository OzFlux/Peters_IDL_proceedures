PRO CheckGRDs
; PURPOSE
;  Procedure to force the 1988 and 1788 vegetation type grids to be
;  consistent, in terms of missing data points, with the monthly LAI
;  grids.
; INPUT
;  Input files are the vegetation type files, either 1788 or 1988, and
;  the monthly LAI files.
; OUTPUT
;  Output files are the same as the input files but with a consistent
;  use of the missing data value.
; DESCRIPTION
;  The vegetation file is read first, then the monthly LAI files.  All
;  inconsistent occurances of the missing data code (1.70141E+038) are
;  then forced to be consistent using the following rules:
;   - if the type cell contains 1.70141E+038 but the corresponding
;     LAI cell contains a valid value then the value of the LAI
;     cell is set to 1.70141E+038
;   - if the LAI cell contains 1.70141E+038 but the corresponding
;     type cell contains a valid value then the value of the type
;     cell is set to 1.70141E+038
;
;  This procedure needs to be used twice, once on the 1988 vegetation
;  type grid and again on the 1788 vegetation type grid.  This will
;  also force the 1988 and 1788 vegetation grids to be consistent.
; USES
;  ReadGRD
;  WriteGRD
; AUTHOR
;  Peter Isaac
; DATE
;  3 February 2005

; *** Declare constants and type variables.
  Months = ['January','February','March','April','May','June','July',$
            'August','September','October','November','December']
;  Months = ['January','February']
;  Months = ['January']
  LAIPath = 'E:\CCAM\Vegetation\LAI\1988'
; *** Get the file names.
  InVEGFile1988 = 'E:\CCAM\Vegetation\Type\1988\ll05b.grd'
  InVEGFile1788 = 'E:\CCAM\Vegetation\Type\1788\ll05b.grd'
  OutVEGFile1988 = STRMID(InVEGFile1988,0,RSTRPOS(InVEGFile1988,'.'))+'_M.grd'
  OutVEGFile1788 = STRMID(InVEGFile1788,0,RSTRPOS(InVEGFile1788,'.'))+'_M.grd'
; *** Read the vegetation type grid files.
  ReadGRD, InVEGFile1988, VEGMeta, VEG1988
  ReadGRD, InVEGFile1788, VEGMeta, VEG1788
  NCol = VEGMeta[0]
  NRow = VEGMeta[1]
; *** First, we force the 1988 and 1788 vegetation type files to be consistent.
  Ind1 = WHERE((VEG1988 NE 1.70141E+038 AND VEG1788 EQ 1.70141E+038), Cnt1)
  Ind2 = WHERE((VEG1988 EQ 1.70141E+038 AND VEG1788 NE 1.70141E+038), Cnt2)
  IF Cnt2 NE 0 THEN VEG1788[Ind2] = 1.70141E+038
  IF Cnt1 NE 0 THEN VEG1988[Ind1] = 1.70141E+038
; *** Loop over the monthly LAI files.
  NMths = N_ELEMENTS(Months)
  FOR i = 0, NMths-1 DO BEGIN
   InLAIFile = LAIPath+'\'+Months[i]+'.grd'
   OutLAIFile = LAIPath+'\'+Months[i]+'_M.grd'
   ReadGRD, InLAIFile, LAIMeta, LAI
; *** Find cells in LAI data that do not equal 1.70141E+038 when the corresponding
; *** cell in the type data does equal 1.70141E+038.
   Ind1 = WHERE((LAI NE 1.70141E+038 AND VEG1988 EQ 1.70141E+038), Cnt1)
; *** Find cells in type data that do not equal 1.70141E+038 when the corresponding
; *** cell in the LAI data does equal 1.70141E+038.
   Ind2 = WHERE((LAI EQ 1.70141E+038 AND VEG1988 NE 1.70141E+038), Cnt2)
; *** Force the two grids to be consistent in their use of the missing data code.
   IF Cnt2 NE 0 THEN VEG1988[Ind2] = 1.70141E+038
   IF Cnt2 NE 0 THEN VEG1788[Ind2] = 1.70141E+038
   IF Cnt1 NE 0 THEN LAI[Ind1] = 1.70141E+038
; *** Write the modified LAI grid to file.
   WriteGRD, OutLAIFile, LAIMeta, LAI, /BINARY
  ENDFOR
; *** Write out the modified vegetation type grid.
  PRINT, OutVEGFile1988
  PRINT, OutVEGFile1788
  WriteGRD, OutVEGFile1988, VEGMeta, VEG1988, /BINARY
  WriteGRD, OutVEGFile1788, VEGMeta, VEG1788, /BINARY

Finish:
END