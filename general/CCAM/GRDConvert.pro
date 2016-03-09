PRO GRDConvert

; PURPOSE
;  Procedure to convert Surfer .GRD from ASCII to binary format
;  or vice versa.
; INPUT
;  Input files are Surfer .GRD files in either ASCII or Surfer V7
;  binary format.
; OUTPUT
;  Output files are Surfer .GRD files in either ASCII or Surfer V7
;  binary format
; DESCRIPTION
; USES
;  ReadGRD
;  WriteGRD
; AUTHOR
;  Peter Isaac
; DATE
;  21 January 2005

; *** Define constants and type variables.
  BlockHeader = '1234'
; *** Set some constants.
  OutFmt = '(F4.1)'
  ZeroToMissing = 0
  MissingToZero = 1
; *** Get the input and output file names.
  Title = 'Select the input file'
  Path = 'C:\Projects\CCAM'
  Filter = '*.grd'
  InFile = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path,GET_PATH=InPath)
  IF InFile EQ '' THEN GOTO, Finish
  Title = 'Specify the output file'
  OutFile = DIALOG_PICKFILE(TITLE=Title,PATH=InPath)
  IF OutFile EQ '' THEN GOTO, Finish

; *** Read the first 4 bytes in the input file to determine if the
; *** file is ASCII or binary.  If the input file is ASCII it will
; *** be converted to binary, if the the input file is binary it
; *** will be converted to ASCII.
  InLun = GETLUN()
  OPENR, InLun, InFile
  READU, InLun, BlockHeader
  FREE_LUN, InLun

  CASE BlockHeader OF
   'DSRB': BEGIN
     ReadGRD, InFile, MetaData, Data
     IF ZeroToMissing EQ 1 THEN BEGIN
      Index = WHERE(Data EQ 0.0, Count)
      PRINT, Count, ' values of 0.0 set to 1.70141E+38'
      IF Count NE 0 THEN Data[Index] = 1.70141E+38
     ENDIF
     IF MissingToZero EQ 1 THEN BEGIN
      Index = WHERE(Data EQ 1.70141E+38, Count)
      PRINT, Count, ' values of 1.70141E+38 set to 0.0'
      IF Count NE 0 THEN Data[Index] = 0.0
     ENDIF
     WriteGRD, OutFile, MetaData, Data, FORMAT=OutFmt
    END
   'DSAA': BEGIN
     ReadGRD, InFile, MetaData, Data
     IF ZeroToMissing EQ 1 THEN BEGIN
      Index = WHERE(Data EQ 0.0, Count)
      PRINT, Count, ' values of 0.0 set to 1.70141E+38'
      IF Count NE 0 THEN Data[Index] = 1.70141E+38
     ENDIF
     IF MissingToZero EQ 1 THEN BEGIN
      Index = WHERE(Data EQ 1.70141E+38, Count)
      PRINT, Count, ' values of 1.70141E+38 set to 0.0'
      IF Count NE 0 THEN Data[Index] = 0.0
     ENDIF
     WriteGRD, OutFile, MetaData, Data, /BINARY
    END
   ELSE: PRINT, 'GRDConvert: Unrecognised .GRD file type'
  ENDCASE
Finish:
END