PRO LAI1788

; PURPOSE
;  Procedure to synthesise monthly LAI files for 1788 using the 1788 and 1988
;  vegetation type data and the 1988 LAI data.
; INPUT
;  Input files are:
;   - the monthly 1988 LAI data (one month at a time at present),
;     binary .GRD file derived from .ASC files
;   - the vegetation type data from 1988 and 1788
; OUTPUT
;
; DESCRIPTION
;
; USES
;  ReadGRD
;  WriteGRD
;  SearchGRD
; AUTHOR
;  Peter Isaac
; DATE
;  27 January 2005

; *** Define constants and type variables.
;  Months = ['January','February','March','April','May','June','July',$
;            'August','September','October','November','December']
  Months = ['December']
; *** Get the vegetation type file names.
  Path = 'E:\CCAM\Vegetation\Type\1988'
  Title = 'Select vegetation file'
  Filter = '*.grd'
  VEGFile1988 = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  IF VEGFile1988 EQ '' THEN GOTO, Finish
  Path = 'E:\CCAM\Vegetation\Type\1788'
  Title = 'Select vegetation file'
  Filter = '*.grd'
  VEGFile1788 = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  IF VEGFile1788 EQ '' THEN GOTO, Finish
; *** Read the vegetation type files.
  ReadGRD, VEGFile1788, VEGMeta1788, VEGData1788
  ReadGRD, VEGFile1988, VEGMeta1988, VEGData1988
  Lon0 = VEGMeta1988[2]
  XSize = VEGMeta1988[3]
  Lat0 = VEGMeta1988[4]
  YSize = VEGMeta1988[5]
; *** Loop over the monthly LAI files.
  NMths = N_ELEMENTS(Months)
  FOR i = 1, NMths DO BEGIN
   StartTime = SYSTIME(1)	; Get the start time for this month
   LAIFile1988 = 'E:\CCAM\Vegetation\LAI\1988\'+Months[i-1]+'_M.grd'
   ReadGRD, LAIFile1988, LAIMeta, LAIData1988
   LAIData1788 = LAIData1988
   SearchGRD,LAIData1788, LAIData1988, VEGData1788, VEGData1988, Stats
   LAIFile1788 = 'E:\CCAM\Vegetation\LAI\1788\'+Months[i-1]+'.grd'
   WriteGRD, LAIFile1788, LAIMeta, LAIData1788, /BINARY
   ElapsedTime = SYSTIME(1) - StartTime
; *** Get the latitude and longitude of the cells where the vegetation type
; *** has changed from 1788 to 1988.
   Lon = Lon0 + Stats[0,*]*XSize
   Lat = Lat0 + Stats[1,*]*YSize
   StatFile = 'E:\CCAM\Vegetation\LAI\1788\'+Months[i-1]+'.dat'
   StatHdr = 'Statistics for nearest neighbour :'+STRING(ElapsedTime,FORMAT='(F8.2)')+' secs'
   PutSer, StatData, Stats[0,*], 'Col'
   PutSer, StatData, Stats[1,*], 'Row'
   PutSer, StatData, Lon, 'Lon'
   PutSer, StatData, Lat, 'Lat'
   PutSer, StatData, Stats[2,*], 'CVeg'
   PutSer, StatData, Stats[3,*], 'NVeg'
   PutSer, StatData, Stats[4,*], 'j'
   PutSer, StatData, Stats[5,*], 'Num'
   PutSer, StatData, Stats[6,*], 'CLAI'
   PutSer, StatData, Stats[7,*], 'NLAI'
   PutSer, StatData, Stats[8,*], 'SdLAI'
   FmtStr = '(I5,I5,F8.3,F8.3,I5,I5,I5,I5,F8.3,F8.3,F8.3)'
   PutFC, StatFile, StatData, StatHdr, FmtStr
  ENDFOR

Finish:
END