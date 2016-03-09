PRO ExtractXYZ

; PURPOSE
;  Extracts a specified region from an (X,Y,Z) format data file.
; INPUT
;  Input files are ASCII, three columns with column A being the X
;  value, column B the Y value and column C the Z value.  X is taken
;  to be longitude and Y is taken to be latitude.
; OUTPUT
;  The output file is the same format as the input file but only
;  contains data points within the specified region.
; DESCRIPTION
;
; USES
; AUTHOR
;  Peter Isaac
; DATE
;  26 May 2005

  A = 0.
  B = 0.
  C = 0.
  XMin = 112.0
  XMax = 155.0
  YMin = -45.0
  YMax = -10.0

; *** Get the input and output file names.
  Path = 'C:\Projects\CCAM\Programmes\Extractd\Data'
  Title = 'Select the input file'
  InFile = DIALOG_PICKFILE(TITLE=Title,PATH=Path)
  Title = 'Specify the output file'
  OutFile = DIALOG_PICKFILE(TITLE=Title,PATH=Path)

  InLun = GETLUN()
  OPENR, InLun, InFile
  OutLun = GETLUN()
  OPENW, OutLun, OutFile

  NR = NumLines(InLun)				; Get the number of lines in the input file.
  X = MAKE_ARRAY(NR,/FLOAT)
  Y = MAKE_ARRAY(NR,/FLOAT)
  Z = MAKE_ARRAY(NR,/FLOAT)
  FOR i = 0, NR-1 DO BEGIN
   READF, InLun, A, B, C
   X(i) = A
   Y(i) = B
   Z(i) = C
  ENDFOR

  XIndex = WHERE((X GE XMin AND X LE XMax), XCount)
  IF XCount NE 0 THEN BEGIN
   X = X[XIndex]
   Y = Y[XIndex]
   Z = Z[XIndex]
  ENDIF
  YIndex = WHERE((Y GE YMin AND Y LE YMax), YCount)
  IF YCount NE 0 THEN BEGIN
   X = X[YIndex]
   Y = Y[YIndex]
   Z = Z[YIndex]
  ENDIF

  N = N_ELEMENTS(X)
  FOR i = 0, N-1 DO BEGIN
   PRINTF, OutLun, X(i), Y(i), Z(i),FORMAT='(2F9.3,I8)'
  ENDFOR

  FREE_LUN, InLun
  FREE_LUN, OutLun

END