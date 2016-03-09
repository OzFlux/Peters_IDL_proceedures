PRO Write3DDat, OutFileName, Array, X, Y, FmtStr
; *** This routine writes a 3D data file.
; *** The file has 3 columns as follows :
; ***      XCoord, YCoord, ZValue
; *** Get the dimensions and size of the array.
   Result = SIZE(Array)
; *** The array must have 2 dimensions to be output as a 3D file.
   IF (Result(0) NE 2) THEN Pause,'Write3DDat: Output array must have 2 dimensions'
; *** Check to see if a file name was passed to this routine, if not
; *** then prompt the user for one.
   IF (N_ELEMENTS(OutFileName) EQ 0) THEN $
    OutFileName = DIALOG_PICKFILE(Title='Specifiy output file name')
   WAIT,0.1
; *** If 'Cancel' was pressed then stop execution.
   IF (STRLEN(OutFileName) EQ 0) THEN RETALL
; *** Number of columns (X) and rows (Y) in the array.
   NCol = Result(1)
   NRow = Result(2)
; *** Check that the array to be output has the same number of rows and
; *** columns as the X and Y arrays.
   IF (N_ELEMENTS(X) NE NCol) THEN BEGIN
    TextMessage = 'X '+CleanString(STRING(N_ELEMENTS(X)))+' and Z '+CleanString(STRING(NCol))+' array have different size'
    Pause, TextMessage
   ENDIF
   IF (N_ELEMENTS(Y) NE NRow) THEN BEGIN
    TextMessage = 'Y '+CleanString(STRING(N_ELEMENTS(Y)))+' and Z '+CleanString(STRING(NRow))+' array have different size'
    Pause, TextMessage
   ENDIF
; *** Parse the format string, if one was present as an argument.
;   IF N_ELEMENTS(FmtStr) EQ 0 THEN FmtStr = 'F10.3'
;   FmtStr = '('+CleanString(STRING(NCol))+CleanString(FmtStr)+')'
; *** Get the next available logical unit number.
   OutLun = GetLun()
   OPENW, OutLun, OutFileName
   FOR i=0,NRow-1 DO BEGIN
    FOR j=0,NCol-1 DO PRINTF, OutLun, X(j), Y(i), Array(j,i)
   ENDFOR
   FREE_LUN, OutLun

END
