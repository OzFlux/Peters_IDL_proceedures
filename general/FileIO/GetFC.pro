PRO GetFC, InFileName, Data, Skip=Skip

; Author	: PRI
; Date		: 03/01/02
; Project	: RAMF
; Mods		:
; Description
;
;  Procedure to read an FC (FORTRAN free format) file created
;  by the RAMF command PUTFC.
;
;  This procedure assumes that the file starts with 2 header
;  lines.  The first header line is read and ignored.  The
;  second header line is assumed to contain a list of column
;  labels giving the names of the data contained in each
;  column.  The labels are assumed to be separated by white
;  space and the number of labels in this line defines the
;  number of columns read from the FC file.

  IF N_ELEMENTS(Skip) EQ 0 THEN Skip = 1
; Open the input file and read the header lines.
  InLun = GetLun()
  OPENR, InLun, InFileName
  NR = NumLines(InLun)				; Get the number of lines in the input file.
  Line = ''
  IF Skip LT 0 THEN ErrorHandler, 'GetFC: Skip less than 0', 1
  IF Skip GT 0 THEN FOR i=1,Skip DO READF, InLun, Line
;  READF, InLun, Line				; Read the first header line.
  READF, InLun, Line				; Read the second header line.
  Line = CleanString(Line)			; Strip out extra space characters

; Check to see if the file uses comma or spaces as delimiters.
  IF (STRPOS(Line,',') NE -1) THEN SepChr = ',' $
  ELSE IF (STRPOS(Line,' ') NE -1) THEN SepChr = ' ' $
  ELSE STOP, 'GetFC: Neither space nor comma detected in 2nd header line'

  Parts = STR_SEP(Line, SepChr)		; Separate into parts
  NS = N_ELEMENTS(Parts)			; Number of labels assumed to be number of data series
  NR = NR - 2						; Number of records is number of lines minus 2
; Tell the user what we are doing.
  NSStr = CleanString(STRING(NS))
  NRStr = CleanString(STRING(NR))
  PRINT, 'Reading '+NSStr+' series of '+NRStr+' records from ', InFileName
; Create the structure to contain the input data.
  Data = {Values:FLTARR(NS,NR),NSer:LONG(0),NRec:LONG(0),Labels:STRARR(NS)}
  Data.NSer = NS
  Data.NRec = NR
; Load the series labels into the structure.
  FOR i = 0, NS-1 DO BEGIN
   Data.Labels(i) = STRTRIM(Parts(i), 2)
  ENDFOR
; Read the data from the input file and load it into the structure.
  DataLine = FLTARR(NS)
  FOR i = 0, NR-1 DO BEGIN
   READF, InLun, DataLine
   Data.Values(*,i) = DataLine
  ENDFOR
; Close the input file.
  FREE_LUN, InLun
END