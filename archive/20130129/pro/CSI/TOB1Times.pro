pro TOB1Info, InFile, SSecs, ESecs

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
HeaderBlock = make_array(HeaderBlockSize, /BYTE)
UArray = make_array(3, /ULONG)
FArray = make_array(NumFields-3, /FLOAT)

openr, InLUN, InFile, /BINARY, /NOAUTOMODE, /GET_LUN
InLUNStat = fstat(InLUN)
RecordSize = NumFields*4
NumRecords = (InLUNStat.size-HeaderBlockSize)/RecordSize
print, InFileName
print, NumRecords, ' records with ', NumFields, ' fields'

readu, InLUN, HeaderBlock
readu, InLUN, UArray, FArray
STime = UArray[0]
FilePointer = HeaderBlockSize+(NumRecords-1)*RecordSize
point_lun, InLUN, FilePointer
readu, InLUN, UArray, FArray
ETime = UArray[0]

free_lun, InLUN

end
