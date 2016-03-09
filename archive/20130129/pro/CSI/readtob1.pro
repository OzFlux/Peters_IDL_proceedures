pro readtob1, InFile, SSecs, ESecs, Header, Time, Data

; *** First we read the file as ASCII to get the 5 header lines.  The size (in bytes)
; *** of the header block is calculated, the file is closed, opened again as binary
; *** and the header block read and discarded before reading the binary data from
; *** each data record.  This is necessary because READU statements that follow
; *** READF statements result in an "end of file" message.  It may be that opening
; *** the file as "/NOAUTOMODE" would prevent this but I have not checked.
Line = ''
Header = make_array(5,/STRING)
openr, InLUN, InFile, /GET_LUN
HeaderBlockSize = 0
for i = 0, 4 do begin
 readf, InLUN, Line
 if i eq 0 then if strupcase(strmid(Line,1,4)) ne 'TOB1' then stop, 'File is not TOB1 type'
 Header[i] = Line
 HeaderBlockSize = HeaderBlockSize + strlen(Line) + 2
 endfor
free_lun, InLUN
; *** Find the number of fields in each record.
; *** First, replace the double quote marks with spaces.
Line = Header[4]
Result = strpos(Line,'"')
while Result ne -1 do begin
 strput, Line, ' ', Result
 Result = strpos(Line,'"')
 endwhile
; *** Then remove all spaces.
Line = strcompress(Line, /REMOVE_ALL)
; *** Divide the string into separate parts.
Parts = str_sep(Line,',')
; *** And finally get the number of fields in each record.
NumFields = size(Parts, /N_ELEMENTS)
NumTimeFields = 3
NumDataFields = NumFields - NumTimeFields

HeaderBlock = make_array(HeaderBlockSize, /BYTE)
UArray = make_array(3, /ULONG)
FArray = make_array(NumFields-3, /FLOAT)
; *** Open the file a second time for binary read.
openr, InLUN, InFile, /BINARY, /NOAUTOMODE, /GET_LUN
; *** Get the file size to calculate the number of records.
InLUNStat = fstat(InLUN)
NumRecords = (InLUNStat.size-HeaderBlockSize)/(NumFields*4)
;print, InFile
;print, NumRecords, ' records with ', NumFields, ' fields'
; *** Declare the time and data arrays.  At this stage we assume there
; *** are three time related fields.  The first is the number of seconds
; *** since 1/1/1990, the second is the number of nanoseconds into the
; *** current second and the third is the record number.
Time = make_array(3,NumRecords, /ULONG)
Data = make_array(NumFields-3,NumRecords, /FLOAT)
; *** Read the header block to position the file pointer at the start
; *** of the first record.
readu, InLUN, HeaderBlock
; *** Decide what to read from the file.
; *** If SSecs =0 and ESecs = 0, read the whole file.
if (SSecs eq 0 AND ESecs eq 0) then begin
 for i = 0, NumRecords-1 do begin
  readu, InLUN, UArray, FArray
  for j = 0, NumTimeFields-1 do Time[j,i] = UArray[j]
  for j = 0, NumDataFields-1 do Data[j,i] = FArray[j]
  endfor
 endif
; *** If SSecs /= 0 and ESecs = 0, read from SSecs to the end of the file.
if (SSecs ne 0 AND ESecs eq 0) then begin
 k = -1
 for i = 0, NumRecords-1 do begin
  readu, InLUN, UArray, FArray
  if (UArray[0] ge SSecs) then begin
   k = k+1
   for j = 0, NumTimeFields-1 do Time[j,k] = UArray[j]
   for j = 0, NumDataFields-1 do Data[j,k] = FArray[j]
   endif
  endfor
  Time = Time[*,0:k]
  Data = Data[*,0:k]
 endif
; *** If SSecs = 0 and ESecs /= 0, read from the start of the file to ESecs.
if (SSecs eq 0 AND ESecs ne 0) then begin
 k = -1
 for i = 0, NumRecords-1 do begin
  readu, InLUN, UArray, FArray
  if (UArray[0] lt ESecs) then begin
   k = k+1
   for j = 0, NumTimeFields-1 do Time[j,k] = UArray[j]
   for j = 0, NumDataFields-1 do Data[j,k] = FArray[j]
   endif
  endfor
  Time = Time[*,0:k]
  Data = Data[*,0:k]
 endif
; *** If SSecs /= 0 and ESecs /= 0, read from SSecs to ESecs.
if (SSecs ne 0 AND ESecs ne 0) then begin
 k = -1
 for i = 0, NumRecords-1 do begin
  readu, InLUN, UArray, FArray
  if (UArray[0] ge SSecs AND UArray[0] lt ESecs) then begin
   k = k+1
   for j = 0, NumTimeFields-1 do Time[j,k] = UArray[j]
   for j = 0, NumDataFields-1 do Data[j,k] = FArray[j]
   endif
  endfor
  Time = Time[*,0:k]
  Data = Data[*,0:k]
 endif

free_lun, InLUN

end
