pro GetB1,InFileName,Data

; Author	: PRI
; Date		: 13/11/94
; Project	: RAMF
; Mods		:
; Description
; Procedure to read a B1 format file.
; General format of a B1 file is as follows ;
; No. of    Record    Description                      Record type
; records   content
;    1      HDR1      Header for whole file            CHARACTER*80
;    1      NSER      Number of series                 INTEGER*4
;  NSER     LABHDR    Label and header for each series CHARACTER*8//CHARACTER*80
; then NRecs of :
; TIME SERIES1 SERIES2 ... SERIESn
; Note that the number of series, NSER, does not include the time series
; so the total number of series in the file is NSER+1

  InLun = GetLun()
  openr,InLun,InFileName			;Open InFileName

; Set up the character variables to be read in.  IDL requires character
; variables to be explicitly "lengthed" ie if you have to read in 80
; characters, the variable needs to be declared as 80 characters by setting
; it equal to an 80 character string.
  Header1 = '01234567890123456789012345678901234567890123456789012345678901234567890123456789'
  Header2 = '01234567'
  NS = LONG(1)

  readu,InLun,Header1	;Read the file header
  readu,InLun,NS		;Read the number of series in the file
; Work out the number of data records in the file.  From the RAMF manual,
; the currnet (12/11/94) B1 format is as follows :
;	A80,INT*4,NSER*(A8,A80),NREC*(REAL*4,(NSER*REAL*4))
  FileStats = FSTAT(InLun)	;Get the file statistics
  NR = LONG((((FileStats.size - 80) - 4) - NS*88)/((NS+1)*4))
  print, 'Reading ', NS,' series of ', NR, ' records from ', InFileName

  Data = {Values:fltarr(NS+1,NR),NSer:long(0),NRec:long(0),Labels:strarr(NS+1)}
  Data.NSer = NS
  Data.NRec = NR

; Now read the labels and headers for each series.  Each series label is
; 8 characters, each series header is 80 characters.
  Data.Labels(0) = 'Tag'
  for i = 1, NS do begin
   readu,InLun,Header2,Header1
   Data.Labels(i) = strtrim(Header2, 2)
;   print,i,' Label="'+Data.Labels(i)+'"'
  endfor
  free_lun, InLun

  offset = NS*88 + 84
  InLun = GetLun()
  openr,InLun,InFileName			;Open InFileName
  B = assoc(InLun,fltarr(NS+1,NR),offset)
  Data.Values = B(0)
  free_lun, InLun					;Close InFileName

finish:
end

