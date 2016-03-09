PRO SearchGRD, LAI1788, LAI1988, VEG1788, VEG1988, Stats
; PURPOSE
;  Procedure to synthesise LAI data for 1788 from 1988 LAI data for
;  those points where the 1788 vegetation type differs from the 1988
;  vegetation type.  The 1988 LAI data is used for 1788 where the
;  vegetation type is unchanged from 1788 to 1988 (approximately
;  80% of the Australian landmass).
; INPUT
;  Four arrays are passed to this routine by the calling procedure:
;   LAI788 - LAI data for 1788, this is a copy of the 1988 LAI
;            data on entry.  On exit, the LAI data for 1788
;            pixels with a different vegetation type from 1988
;            will have been replaced by LAI data from the nearest
;            1988 pixels with the 1788 vegetation type.
;   LAI1988 - LAI data for 1988
;   VEG1788 - 1788 vegetation type data
;   VEG1988 - 1988 vegetation type data
; OUTPUT
;  See INPUT section.
; DESCRIPTION
;  The 1988 LAI data is used for 1788 where the vegetation type does
;  not differ between 1788 and 1988, this amounts to about 80% of the
;  Australian landmass.
;
;  The grid cells where the 1788 and 1988 vegetation types differ are
;  identified first.  This procedure then loops over these points and
;  searches the 1988 vegetation type grid outwards from the initial
;  point until grid cells of the 1788 vegetation type are found.  The
;  1988 LAI data for these grid cells is then used for the initial 1788
;  grid cell.  This technique substitutes the 1788 LAI data for grid
;  cells with changed vegetation type with the nearest neighbour LAI
;  data for that vegetation type.
;
;  At present, the search outward from the initial point is done by
;  defining ever larger squares surrounding the initial point and
;  searching these squares for occurances of the 1788 vegetation type.
;  The squares are increased by a row either side and a column either
;  side of the previous square, that is by 2 rows and 2 columns at
;  each step.  The first step would be a square of 1x1 (rowsxcolumns)
;  but we already know that the 1788 and 1988 vegetation types differ
;  for this grid cell.  The second step is a square of 3x3, the third
;  step is a square of 5x5 and so on.
;
;  As a first attempt, the whole square will be searched each time but
;  this is very inefficient because the inner squares have already been
;  searched before.  A more efficient method would be to extract the
;  outer ring of cells, search only these and keep the results until
;  a sufficient number of "nearest neighbours" have been found.
; USES
;
; AUTHOR
;  Peter Isaac
; DATE
;  27 January 2005

; *** Declare, type and set variables.
  MinFound = 10		; Minimum number of "nearest neighbours" to find
  i = LONG(0)
; *** Check that all arrays are the same size and then get the number
; *** of columns.
  Sa = SIZE(LAI1788)
  Sb = SIZE(LAI1988)
  Sc = SIZE(VEG1788)
  Sd = SIZE(VEG1988)
  IF (Sa[1] NE Sb[1]) OR (Sa[1] NE Sc[1]) OR (Sa[1] NE Sd[1]) THEN $
   ErrorHandler, 'SearchGRD: Input arrays have different number of columns', 1
  IF (Sa[2] NE Sb[2]) OR (Sa[2] NE Sc[2]) OR (Sa[2] NE Sd[2]) THEN $
   ErrorHandler, 'SearchGRD: Input arrays have different number of rows', 1
  NCols = Sa[1]
  NRows = Sa[2]
; *** Get the indices of the grid cells where the 1788 and 1988 vegetation
; *** types differ.
  VDiffInd = WHERE(VEG1788 NE VEG1988, VDiffCnt)
  IF VDiffCnt EQ 0 THEN GOTO, Finish
;  VDiffCnt = 1000
  Stats = MAKE_ARRAY(9, VDiffCnt)
; *** Loop over the grid cells where 1788 and 1988 vegetation types
; *** differ, search outward from each cell to find the nearest neighbour
; *** vegetation type in the 1988 data and get the LAI data of the
; *** nearest neighbour points.
  FOR i = LONG(0), VDiffCnt-1 DO BEGIN
   IF (i MOD 1000) EQ 0 THEN PRINT, 'i=',i
   Row = FIX(VDiffInd[i]/NCols)
   Col = FIX(VDiffInd[i] - Row*NCols)
   VType = VEG1788[Col,Row]
   NumFound = 0
   j = 0
   WHILE NumFound LT MinFound DO BEGIN
    j = j + 5
    R1 = MAX([Row-j,0])		; Don't go outside the array bounds
    R2 = MIN([Row+j,NRows-1])
    C1 = MAX([Col-j,0])
    C2 = MIN([Col+j,NCols-1])
    SubVEG = VEG1988[C1:C2,R1:R2]
    SubLAI = LAI1988[C1:C2,R1:R2]
    SubInd = WHERE(SubVEG EQ VType, NumFound)
   ENDWHILE
   LAI1788[Col,Row] = MEAN(SubLAI[SubInd])
   SdLAI = STDDEV(SubLAI[SubInd])
   Stats[0,i] = Col
   Stats[1,i] = Row
   Stats[2,i] = VEG1988[Col,Row]
   Stats[3,i] = VEG1788[Col,Row]
   Stats[4,i] = j
   Stats[5,i] = NumFound
   Stats[6,i] = LAI1988[Col,Row]
   Stats[7,i] = LAI1788[Col,Row]
   Stats[8,i] = SdLAI
;   PRINT,LAI1988[Col,Row]
;   PRINT,SubLAI[SubInd]
;   PRINT,Stats[*,i],FORMAT='(6I8,3F8.3)'
  ENDFOR

Finish:
END