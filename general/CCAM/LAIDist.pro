PRO LAIDist

; PURPOSE
;  Procedure to calculate the distribution of LAI for a given vegetation
;  type.
; INPUT
;  Input files are:
;   - the monthly LAI data (one month at a time at present),
;     binary .GRD file derived from .ASC files
;   - the vegetation type data (either 1988 or 1788),
;     ASCII .GRD file ex YPW
; OUTPUT
;
; DESCRIPTION
;
; USES
;  ReadGRD
; AUTHOR
;  Peter Isaac
; DATE
;  21 January 2005

; *** Define constants and type variables.
  Months = ['January','February','March','April','May','June','July',$
            'August','September','October','November','December']
;  Months = ['January']
  LAIPath = 'E:\CCAM\Vegetation\LAI\1988'
  VType = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,$
           21,22,23,24,25,26,27,28,29,30,31]
;  VType = [4,5,9,11,12,14,20,21,24,25]
; *** Get the vegetation type file name and read the vegetation type file.
  Path = 'E:\CCAM\Vegetation\Type\1988'
  Title = 'Select vegetation file'
  Filter = '*.grd'
  VEGFile = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  IF VEGFile EQ '' THEN GOTO, Finish
  ReadGRD, VEGFile, VEGMeta, VEGData

; *** Loop over the monthly LAI files.
  NMths = N_ELEMENTS(Months)
  NTyps = N_ELEMENTS(VType)
  LAIBinSize = 0.2
  LAIMin = 0.0 - LAIBinSize/2.0
  LAIMax = 8.0 + LAIBinSize/2.0
  NBins = FIX((LAIMax - LAIMin)/LAIBinSize) + 1
  BinMidPts = FINDGEN(NBins)*LAIBinSize
; *** LAIDist will hold the LAI distributions for each vegetation type
; *** for each month plus the LAI distribution for all types (hence the
; *** dimensioning as NTyps+1).
  LAIDist = MAKE_ARRAY(NTyps+1, NBins, NMths, /LONG, VALUE=0)
; *** Loop over the months, read the LAI .GRD files and get the LAI distributions.
  FOR i = 1, NMths DO BEGIN
   LAIFile = LAIPath+'\'+Months[i-1]+'.grd'
   ReadGRD, LAIFile, LAIMeta, LAIData
;   LAIData = VEGData/4.0	; Debug method, produces known LAI distribution
; *** Get a histogram of all LAI values regardless of vegetation type.
   Index = WHERE(LAIData NE LAIMeta[9], Count)
   IF Count NE 0 THEN LAI4Type = LAIData[Index] ELSE LAI4Type = LAIData
   Hist = HISTOGRAM(LAI4Type,BINSIZE=LAIBinSize,MIN=LAIMin,MAX=LAIMax)
   LAIDist[NTyps,*,i-1] = Hist
; *** Now loop over all vegetation types.
   FOR j = 1, NTyps DO BEGIN
    Index = WHERE(VEGData EQ VType[j-1], Count)
    IF Count NE 0 THEN LAI4Type = LAIData[Index] ELSE LAI4Type = [LAIMax+1.0]
    Hist = HISTOGRAM(LAI4Type,BINSIZE=LAIBinSize,MIN=LAIMin,MAX=LAIMax)
    LAIDist[j-1,*,i-1] = Hist
   ENDFOR
  ENDFOR

; *** Write the LAI distributions to file, one file for each vegetation type.
  FOR j = 1, NTyps DO BEGIN
   HistFile = LAIPath+'\LAIForVegType'+STRING(VType[j-1],FORMAT='(I2.2)')+'.dat'
   HistHeader = 'Histogram of LAI values for vegetation type '+STRING(VType[j-1],FORMAT='(I2)')$
               +' : '+STRING(LAIBinSize,FORMAT='(F5.2)')+' '+STRING(LAIMin,FORMAT='(F5.2)')$
               +' '+STRING(LAIMax,FORMAT='(F5.2)')
   PutSer, OutData, BinMidPts, 'Mid'
   FOR i = 1, NMths DO BEGIN
    PutSer, OutData, LAIDist[j-1,*,i-1], Months[i-1]
   ENDFOR
   FmtStr = '(F5.2,'+STRING(NMths)+'I10)'
   PutFC, HistFile, OutData, HistHeader, FmtStr
   OutData = 0.0
  ENDFOR
; *** Write out the LAI distribution for all vegetation types.
  HistFile = LAIPath+'\LAIForVegType32.dat'
  HistHeader = 'Histogram of LAI values for all vegetation types : '+$
               STRING(LAIBinSize,FORMAT='(F5.2)')+' '+STRING(LAIMin,FORMAT='(F5.2)')+$
               ' '+STRING(LAIMax,FORMAT='(F5.2)')
  PutSer, OutData, BinMidPts, 'Mid'
  FOR i = 1, NMths DO BEGIN
   PutSer, OutData, LAIDist[NTyps,*,i-1], Months[i-1]
  ENDFOR
  FmtStr = '(F5.2,'+STRING(NMths)+'I10)'
  PutFC, HistFile, OutData, HistHeader, FmtStr
  OutData = 0.0
Finish:
END