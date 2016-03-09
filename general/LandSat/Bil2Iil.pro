PRO Bil2Iil
; AUTHOR: PRI
; DATE: Unknown
; PURPOSE:
;  Reads the LandSat data supplied by Alan Marks and writes the data out in
;  a different format.
;
;  The image data supplied by Alan Marks is in band-interleaved format (.BIL).
;  In this format, the first line in the file is the first line of the image
;  for TM band 1, the second line is the first line of the image for TM band
;  2, the third line is the first line of the image for TM band 3 etc.  Each
;  image line is repeated 7 times, once for each TM band.  This format is
;  commonly used but is rather hard to manipulate using IDL.  This procedure
;  reads the band-interleaved format file for each band in turn and then
;  writes the whole image for the given band to file ie image-interleaved
;  format.  The output file, .IIL, can then be opened in IDL and associated with
;  a byte array of the same dimensions as the image.  Whole images can then
;  be accessed and read from the .IIL file much more quickly.
; INPUTS:
; OUTPUTS:
; METHOD:
; USES:

TM = BYTARR(5202,2002)

OPENR, 1, 'e:\oasis95\landsat\bil\lockhart.bil', /BINARY, /NOAUTOMODE
OPENR, 2, 'e:\oasis95\landsat\data\wt.iil', /BINARY, /NOAUTOMODE

l = ASSOC(1,BYTARR(5202,14014))

i = INDGEN(2002)

FOR m = 1, 7 DO BEGIN
 PRINT, 'Processing TM band ', m
 n = 7*i + (m-1)
 TM(*,i) = l[*,n,0]
 PRINT, 'Writing TM band ', m,' to file'
 WRITEU, 2, TM
ENDFOR

CLOSE, 1
CLOSE, 2

END
