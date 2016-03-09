PRO ReadASC, InFileName, MetaData, Data

; PURPOSE
;  Reads a .ASC format file and returns two arrays, one containing
;  the data itself and the other containing the coordinates of the
;  lower left corner (in latitude and longitude for the LAI .ASC
;  files), the cell size (0.05 degrees) and the NODATA value.
; INPUT
;  The filename of a .ASC format file.
; OUTPUT
;  Returns two arrays of data.
; DESCRIPTION
;
; AUTHOR
;  Peter Isaac
; DATE
;  16 January 2005

; *** Declare constants and type variables.
  HDRLine = ''
  RDmy = 0.0
; *** Open the input .ASC file.
  ASCLun = GETLUN()
  OPENR, ASCLun, InfileName
; *** Read the header information as follows:
; *** Line   Description                                Index in TempMeta
; ***  1st   number of columns                          0
; ***  2nd   number of rows                             1
; ***  3rd   X coordinate of lower left corner          2
; ***  4th   Y coordinate of lower left corner          3
; ***  5th   grid cell size                             4
; ***  6th   value used to indicate no (missing) data   5
  MetaData = MAKE_ARRAY(10,/FLOAT)
  TempMeta = MAKE_ARRAY(6,/FLOAT)
  FOR i = 0, 5 DO  BEGIN
   READF, ASCLun, HDRLine
   StrParts = STR_SEP(STRCOMPRESS(HDRLine),' ')
   READS, StrParts[1], RDmy
   TempMeta[i] = RDmy
  ENDFOR
; *** Put the required information into the MetaData array.
  MetaData[0] = TempMeta[0]		; number of columns
  MetaData[1] = TempMeta[1]		; number of rows
  MetaData[2] = TempMeta[2]		; minimum X coordinate
  MetaData[3] = TempMeta[4]		; X cell size
  MetaData[4] = TempMeta[3]		; minimum Y coordinate
  MetaData[5] = TempMeta[4]		; Y cell size
  MetaData[8] = 0.0				; rotation
  MetaData[9] = TempMeta[5]		; blanking value
; *** Now read the data from the .ASC file and place in in the array Data.
  NCol = MetaData[0]
  NRow = MetaData[1]
  OneLine = MAKE_ARRAY(NCol, /FLOAT)
  Data = MAKE_ARRAY(NCol, NRow, /FLOAT)
  FOR i = 0, NRow-1 DO BEGIN
   READF, ASCLun, OneLine
   Data[*,i] = OneLine
  ENDFOR
; *** Now get the minimum and maximum Z values excluding the missing data code.
  Index = WHERE(Data NE MetaData[9], Count)
  IF Count NE 0 THEN MetaData[6] = MIN(Data[Index]) ELSE MetaData[6] = MIN(Data)
  IF Count NE 0 THEN MetaData[7] = MAX(Data[Index]) ELSE MetaData[7] = MAX(Data)
; *** Close the file and return.
  FREE_LUN, ASCLun

END