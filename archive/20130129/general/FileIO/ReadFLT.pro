PRO ReadFLT, FLTFileName, MetaData, Data

; PURPOSE
;  Reads an ArcView .FLT format file and returns two arrays, one containing
;  the data itself and the other containing the number of columns, the
;  number of rows and the minimum and maximum X, Y and Z coordinates.
; INPUT
;  The filename of a .FLT format file.
; OUTPUT
;  Returns two arrays of single precision floating point data.  Note that the
;  binary .FLT file format uses single precision and the file is read at this
;  precision.
;  Contents of MetaData are as follows:
;   MetaData[0] - number of columns in grid
;   MetaData[1] - number of rows in grid
;   MetaData[2] - minimum X coordinate of grid
;   MetaData[3] - X cell size
;   MetaData[4] - minimum Y coordinate of grid
;   MetaData[5] - Y cell size
;   MetaData[6] - minimum Z value of grid
;   MetaData[7] - maximum Z value of grid
;   MetaData[8] - rotation (not currently used)
;   MetaData[9] - no data value
; DESCRIPTION
; LIMITATIONS
; AUTHOR
;  Peter Isaac
; DATE
;  14 April 2005

; *** Declare constants and type variables.
  HDRLine = ''
  RDmy = 0.0
  NCol = LONG(0)
  NRow = LONG(0)
  MetaData = MAKE_ARRAY(10, /FLOAT)
  TempMeta = MAKE_ARRAY(6, /FLOAT)

; *** Open the input .HDR file and read in the number of rows, columns etc.
  ExtPosition = RSTRPOS(FLTFileName,'.') + 1
  HDRFileName = FLTFileName
  STRPUT, HDRFileName, 'hdr', ExtPosition
  HDRLun = GETLUN()
  OPENR, HDRLun, HDRFileName
  FOR i = 0, 5 DO BEGIN
   READF, HDRLun, HDRLine
   StrParts = STR_SEP(STRCOMPRESS(STRTRIM(HDRLine,2)),' ')
   READS, StrParts[1], RDmy
   TempMeta[i] = RDmy
  ENDFOR
  FREE_LUN, HDRLun
  MetaData[0] = TempMeta[0]				; Number of columns
  MetaData[1] = TempMeta[1]				; Number of rows
  MetaData[2] = TempMeta[2]				; X minimum
  MetaData[3] = TempMeta[4]				; X cell size
  MetaData[4] = TempMeta[3]				; Y minimum
  MetaData[5] = TempMeta[4]				; Y cell size
  MetaData[8] = 0.0						; Rotation (not used)
  MetaData[9] = TempMeta[5]				; No data value
; *** Now declare the data array, open the .FLT file and read the contents.
  NCol = MetaData[0]
  NRow = MetaData[1]
  Data = MAKE_ARRAY(NCol, NRow, /FLOAT)
  FLTLun = GETLUN()
  OPENR, FLTLun, FLTFileName
  READU, FLTLun, Data
  FREE_LUN, FLTLun
; *** Get the minimum and maximum values in Data and put these into MetaData.
  MetaData[6] = MIN(Data)
  MetaData[7] = MAX(Data)

END