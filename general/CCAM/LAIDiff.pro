PRO LAIDiff

; PURPOSE
;  Procedure to output a grid file of LAI differences between 1788 and 1988.
; INPUT
; OUTPUT
; DESCRIPTION
; USES
;  ReadGRD
; AUTHOR
;  Peter Isaac
; DATE
;  4 February 2005

; *** Declare constants and type variables.
  Months = ['January','February','March','April','May','June','July',$
            'August','September','October','November','December']
;  Months = ['January']
; *** Loop over the months.
  NMths = N_ELEMENTS(Months)
  FOR i = 1, NMths DO BEGIN
; *** Get the file names.
   LAIFile1788 = 'E:\CCAM\Vegetation\LAI\1788\'+Months[i-1]+'.grd'
   LAIFile1988 = 'E:\CCAM\Vegetation\LAI\1988\'+Months[i-1]+'.grd'
; *** Read the 1788 and 1988 monthly LAI grids.
   ReadGRD, LAIFile1788, LAIMeta1788, LAIData1788
   ReadGRD, LAIFile1988, LAIMeta1988, LAIData1988
; *** Get the LAI differences and reset the sea to the missing data code.
   LAIDiff = LAIData1788 - LAIData1988
   Index = WHERE(LAIData1988 EQ 1.70141E+038, Count)
   IF Count NE 0 THEN LAIDiff[Index] = 1.70141E+038
; *** Write the type differences to a grid file.
   LDFile = 'E:\CCAM\Vegetation\LAI\Differences\'+Months[i-1]+'.grd'
   LAIMetaDiff = LAIMeta1988
   LAIMetaDiff[6] = MIN(LAIDiff)
   LAIMetaDiff[7] = MAX(LAIDiff)
   WriteGRD, LDFile, LAIMetaDiff, LAIDiff, /BINARY
  ENDFOR

END