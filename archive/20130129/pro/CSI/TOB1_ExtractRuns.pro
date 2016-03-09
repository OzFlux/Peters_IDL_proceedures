pro TOB1_ExtractRuns

InFile='d:\spofatte\sites\adelaideriver\data\raw\TOB1_CR3000_Ad_River_01_Feb_2008_ts_data.dat'
InFilePath = strmid(InFile,0,rstrpos(InFile,'\'))
; *** Get the start and end date/time for the file.
jdcnv, 1990, 1, 1, 0, ZJDay
tob1info, InFile, FSSecs, FESecs
FSDays = double(FSSecs)/double(86400.0)
FJDay = ZJDay + FSDays + 5.787E-6
caldat, FJDay, FSMonth, FSDay, FSYear, FSHour, FSMinute, FSSecond
SDateTime = string(FSDay,'/',FSMonth,'/',FSYear,' ',FSHour,':',FSMinute,':',FSSecond, $
                   format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
FEDays = double(FESecs)/double(86400.0)
FJDay = ZJDay + FEDays + 5.787E-6
caldat, FJDay, FEMonth, FEDay, FEYear, FEHour, FEMinute, FESecond
EDateTime = string(FEDay,'/',FEMonth,'/',FEYear,' ',FEHour,':',FEMinute,':',FESecond, $
                   format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
print, 'File contains data from ', SDateTime, ' to ', EDateTime
; *** Ask the user for the time periods of the runs.
read, RunPeriod, prompt='Enter the run period in seconds (eg 1800 for 30 minutes): '
read, ScanPeriod, prompt='Enter the scan period in seconds (eg 0.1 for 10 Hz): '
; *** Get the start time of the first run.
if ((FSSecs MOD RunPeriod) eq 0) then begin
 RSSecs = ulong(FSSecs)
endif else begin
 RSSecs = ulong((1+ulong(FSSecs/RunPeriod))*ulong(RunPeriod))
endelse
; *** Loop over the file read until we reach the end of the file.
; *** First, we read the header block.
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
; *** Declare a byte array with the same size as the header block.  This will
; *** be used to read over the header lines when the file is read as binary.
HeaderBlock = make_array(HeaderBlockSize, /BYTE)
UArray = make_array(NumTimeFields, /ULONG)
FArray = make_array(NumDataFields, /FLOAT)
RecordSize = NumTimeFields*4 + NumDataFields*4
; *** Open the file a second time for binary read.
openr, InLUN, InFile, /BINARY, /NOAUTOMODE, /GET_LUN
; *** Get the file size to calculate the number of records.
InLUNStat = fstat(InLUN)
;NumRecords = (InLUNStat.size-HeaderBlockSize)/(NumFields*4)
NumRecords = RunPeriod/ScanPeriod
Time = make_array(NumTimeFields,NumRecords, /ULONG)
Data = make_array(NumDataFields,NumRecords, /FLOAT)
; *** Read the header block to position the file pointer at the start
; *** of the first record.
readu, InLUN, HeaderBlock
; *** The file pointer is now positioned at the start of the first data
; *** record.  We now read forward, if necessary, until we reach the
; *** required start time RSSecs.
if FSSecs lt RSSecs then begin
 CSecs = FSSecs
 while CSecs lt RSSecs do begin
  readu, InLUN, UArray, FArray
  CSecs = UArray[0]
  endwhile
 point_lun, -InLUN, LUNPsn
 LUNPsn = LUNPsn - RecordSize
 point_lun, InLUN, LUNPsn
endif
readu, InLUN, UArray, FArray
for j = 0, NumTimeFields-1 do Time[j,0] = UArray[j]
for j = 0, NumDataFields-1 do Data[j,0] = FArray[j]
print, FSSecs, RSSecs, CSecs, UArray[0]

end