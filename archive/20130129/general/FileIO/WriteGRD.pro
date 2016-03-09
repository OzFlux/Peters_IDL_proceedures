PRO WriteGRD, GRDFile, MetaData, Data, FORMAT=GRDFmt, BINARY=BINARY

; *** This routine writes a .GRD file for SURFER.
; *** GRD output format options are ASCII (default) or Surfer 7 (BINARY),
; *** see the Surfer 7 help files for details on the format.

; *** Get the dimensions and size of the array.
   Result = SIZE(Data)
; *** The array must have 2 dimensions to be output as a .GRD file.
   IF (Result[0] NE 2) THEN Pause, 'WriteGRD: Output array must have 2 dimensions'
; *** Open the .GRD file.
   OutLun = GetLun()
   OPENW, OutLun, GrdFile
; *** Write the .GRD, ASCII or binary depends on whether the keyword 'BINARY'
; *** has been set.
   CASE 1 OF
    KEYWORD_SET(BINARY): BEGIN
      PRINT, GRDFile, ' will be written as a binary .GRD file'
      BlockHeader = 'DSRB'
      BlockLength = LONG(4)
      Version = LONG(1)
      WRITEU,OutLun,BlockHeader,BlockLength,Version
      BlockHeader = 'GRID'
      BlockLength = LONG(72)
      NCol = LONG(MetaData[0])
      NRow = LONG(MetaData[1])
      xLL = DOUBLE(MetaData[2])
      xSize = DOUBLE(MetaData[3])
      yLL = DOUBLE(MetaData[4])
      ySize = DOUBLE(MetaData[5])
      zMin = DOUBLE(MetaData[6])
      zMax = DOUBLE(MetaData[7])
      Rotation = DOUBLE(MetaData[8])
      BlankValue = DOUBLE(MetaData[9])
      WRITEU,OutLun,BlockHeader,BlockLength,NRow,NCol,xLL,yLL,xSize,ySize,zMin,zMax,Rotation,BlankValue
      BlockHeader = 'DATA'
      BlockLength = LONG(8*Result[4])
;      WRITEU,OutLun,BlockHeader,BlockLength,DOUBLE(REVERSE(Data,2))
      WRITEU,OutLun,BlockHeader,BlockLength,DOUBLE(Data)
     END
    ELSE: BEGIN
      PRINT, GRDFile, ' will be written as an ASCII .GRD file'
; *** Parse the format string, if one was present as an argument.
      IF N_ELEMENTS(GRDFmt) EQ 0 THEN GRDFmt = 'E13.5'
      NCol = LONG(MetaData[0])
      NRow = LONG(MetaData[1])
      xLL = MetaData[2]
      xTR = xLL + MetaData[3]*(NCol-1)
      yLL = MetaData[4]
      yTR = yLL + MetaData[5]*(NRow-1)
      FmtStr = '('+CleanString(STRING(NCol))+CleanString(GRDFmt)+')'
      PRINTF, OutLun, 'DSAA'
      PRINTF, OutLun, NCol, NRow, FORMAT='(2I10)'
      PRINTF, OutLun, xLL, xTR, FORMAT='(2F10.3)'
      PRINTF, OutLun, yLL, yTR, FORMAT='(2F10.3)'
      PRINTF, OutLun, MetaData[6], MetaData[7], FORMAT=FmtStr
;      FOR i=NRow-1,0,-1 DO PRINTF, OutLun, Data(*,i), FORMAT=FmtStr
      FOR i=0,NRow-1 DO PRINTF, OutLun, Data(*,i), FORMAT=FmtStr
     END
   ENDCASE
   FREE_LUN, OutLun
END
