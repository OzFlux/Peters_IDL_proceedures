PRO TypeDiff

; PURPOSE
;  Procedure to identify grid cells with different vegetation types in
;  1788 and 1988.
; INPUT
;  Input files are the 1788 and 1988 vegetation type files, these
;  are Surfer .GRD files derived from the AUSLIG data by DG.
; OUTPUT
; DESCRIPTION
; USES
;  ReadGRD
; AUTHOR
;  Peter Isaac
; DATE
;  21 January 2005

; *** Declare constants and type variables.

; *** Get the file names.
  Title = 'Select the current vegetation type file'
  Filter = '*.grd'
  Path = 'E:\CCAM\Vegetation\Type\1988'
  CTypeFile = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  Title = 'Select the native vegetation type file'
  Filter = '*.grd'
  Path = 'E:\CCAM\Vegetation\Type\1788'
  NTypeFile = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)

; *** Read the vegetation type grid files.
  ReadGRD, CTypeFile, CTypeMeta, CTypeData
  ReadGRD, NTypeFile, NTypeMeta, NTypeData
  NCol = CTypeMeta[0]
  NRow = CTypeMeta[1]
; *** Get the grid cells where the vegetation types have changed.
  TypeDiff = MAKE_ARRAY(NCol, NRow, /FLOAT, VALUE=31)	; Make the array
  Index = WHERE(CTypeData EQ 1.70141E+38, Count)		; Identify water cells
  IF Count NE 0 THEN TypeDiff[Index] = 1.70141E+38		; Set difference to blank value
  Index = WHERE(NTypeData EQ 1.70141E+38, Count)
  IF Count NE 0 THEN TypeDiff[Index] = 1.70141E+38
  Index = WHERE(CTypeData NE NTypeData, Count)			; Identify differences
  IF Count NE 0 THEN TypeDiff[Index] = 7
; *** Write the type differences to a grid file.
  TDFile = 'E:\CCAM\Vegetation\Type\1988\TDiffs.grd'
  WriteGRD, TDFile, CTypeMeta, TypeDiff, /BINARY
; *** Statistics of changed vegetation types.
  NHist = HISTOGRAM(NTypeData, BINSIZE=1, MIN=1, MAX=31)
  CHist = HISTOGRAM(CTypeData, BINSIZE=1, MIN=1, MAX=31)
  DHist = HISTOGRAM(NTypeData[Index], BINSIZE=1, MIN=1, MAX=31)
  NTypePC = 100.0*NHist/TOTAL(NHist)
  CTypePC = 100.0*CHist/TOTAL(CHist)
  DTypePC = NTypePC - CTypePC
  FOR i = 0, 30 DO PRINT, i, NHist[i],NTypePC[i],CHist[i],CTypePC[i],$
                             DHist[i],DTypePC[i],FORMAT='(I3,I8,F8.2,I8,F8.2,I8,F8.2)'
  HistFile = 'E:\CCAM\Vegetation\Type\1988\Diffs.dat'
  FCHeader = 'Histogram of changed vegetation types: 1788 to 1988'
  Bins = INDGEN(31) + 1
  PutSer, Data, Bins, 'Type'
  PutSer, Data, NHist, 'NHist'
  PutSer, Data, NTypePC, 'NType%'
  PutSer, Data, CHist, 'CHist'
  PutSer, Data, CTypePC, 'CType%'
  PutSer, Data, DHist, 'DHist'
  PutSer, Data, DTypePC, 'DType%'
  PutFC, HistFile, Data, FCHeader, '(I3,I8,F8.2,I8,F8.2,I8,F8.2)'
; *** Reduce the vegetation type grids by a factor of two and plot.
  CTypeData[WHERE(CTypeData EQ 1.70141E+38)] = 0.0
  NTypeData[WHERE(NTypeData EQ 1.70141E+38)] = 0.0
  TypeDiff[WHERE(TypeDiff EQ 1.70141E+38)] = 0.0
  CData = REBIN(CTypeData, NCol/2, NRow/2)
  NData = REBIN(NTypeData, NCol/2, NRow/2)
  TData = REBIN(TypeDiff, NCol/2, NRow/2)
  WINDOW, /FREE, XSIZE=860, YSIZE=700
  TVSCL, NData, 0
  TVSCL, CData, 1
  TVSCL, TData, 2

END