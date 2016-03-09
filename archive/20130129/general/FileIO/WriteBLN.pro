PRO WriteBLN, OutFileName, X, Y, Flag, PName=PName, FmtStr=FmtStr
; *** This routine writes a SURFER .BLN data file.
; *** The file format is as follows:
; ***    length,flag,"PName1"
; ***     x1,y1
; ***     x2,y2
; ***      .  .
; ***      .  .
; ***     xn,yn
; ***    length,flag,"PName2"
; ***     x1,y1
; ***     x2,y2
; ***      .  .
; ***      .  .
; ***      .  .
; ***     xn,yn
; *** where length is the number of points, flag indicates the region to be
; *** blanked (1 ==> blank inside, 0 ==> blank outside) and PName is the
; *** (optional) name of the object.  The data pairs (x1,y1) to (xn,yn)
; *** describe the outline of the blanking region.
; *** See the SURFER help for further detials.
; *** Get the dimensions and size of the array.
   ResultX = SIZE(X)
   ResultY = SIZE(Y)
; *** The arrays must have 1 dimension to be output as a BLN file.
   IF (ResultX(0) NE 1) THEN Pause,'WriteBLN: Output X array must have 1 dimension'
   IF (ResultY(0) NE 1) THEN Pause,'WriteBLN: Output Y array must have 1 dimension'
   IF (ResultX(1) NE ResultY(1)) THEN Pause,'WriteBLN: Output X and Y arrays have different sizes'
; *** Check to see if a file name was passed to this routine.
   IF (N_ELEMENTS(OutFileName) EQ 0) THEN Pause,'WriteBLN: No filename passed to routine'
; *** Number of points to to output.
   NPts = ResultX(1)
; *** Get the next available logical unit number and open the file.
   OutLun = GetLun()
   OPENW, OutLun, OutFileName
; *** Write out the data.
   IF (N_ELEMENTS(PName) EQ 0) THEN PRINTF,OutLun,NPts,Flag,FORMAT='(2I8)'
   IF (N_ELEMENTS(PName) NE 0) THEN PRINTF,OutLun,NPts,Flag,PName,FORMAT='(2I8,1X,A)'
   IF (N_ELEMENTS(FmtStr) EQ 0) THEN FOR i=0,NPts-1 DO PRINTF,OutLun,X(i),Y(i)
   IF (N_ELEMENTS(FmtStr) NE 0) THEN FOR i=0,NPts-1 DO PRINTF,OutLun,X(i),Y(i),FORMAT=FmtStr
; *** Close the file and free up the logical unit number.
   FREE_LUN, OutLun

END
