PRO CheckType
; PURPOSE
;  Procedure to check 1788 and 1988 vegetation grids for consistency.
; INPUT
;  Input files are the 1788 and 1988 vegetation type files, these
;  are Surfer .GRD files derived from the AUSLIG data by DG.
; OUTPUT
; DESCRIPTION
; USES
;  ReadGRD
; AUTHOR
;  Peter Isaac
; DATE
;  29 January 2005

; *** Declare constants and type variables.

; *** Get the file names.
  Title = 'Select the 1988 vegetation type file'
  Filter = '*.grd'
  Path = 'E:\CCAM\Vegetation\Type\1988'
  VEGFile1988 = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  Title = 'Select the 1788 vegetation type file'
  Filter = '*.grd'
  Path = 'E:\CCAM\Vegetation\Type\1788'
  VEGFile1788 = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
; *** Read the vegetation type grid files.
  ReadGRD, VEGFile1988, VEGMeta1988, VEG1988
  ReadGRD, VEGFile1788, VEGMeta1788, VEG1788
  NCol = VEGMeta1988[0]
  NRow = VEGMeta1988[1]
; *** Check that the same cells in 1788 and 1988 have a value of 1.70141E+038
  Ind1788B = WHERE(VEG1788 EQ 1.70141E+038, Cnt1788B)
  Ind1788V = WHERE(VEG1788 NE 1.70141E+038, Cnt1788V)
  Ind1988B = WHERE(VEG1988 EQ 1.70141E+038, Cnt1988B)
  Ind1988V = WHERE(VEG1988 NE 1.70141E+038, Cnt1988V)
  Ind1 = WHERE(VEG1788[Ind1988B] NE 1.70141E+038, Cnt1)
  Ind2 = WHERE(VEG1988[Ind1788B] NE 1.70141E+038, Cnt2)
  Ind3 = WHERE(VEG1788[Ind1988V] EQ 1.70141E+038, Cnt3)
  Ind3 = WHERE(VEG1988[Ind1788V] EQ 1.70141E+038, Cnt4)
  PRINT, Cnt1788B, Cnt1988B, Cnt1788V, Cnt1988V, Cnt1, Cnt2, Cnt3, Cnt4

END