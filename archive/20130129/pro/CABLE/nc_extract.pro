pro nc_extract
; PROJECT: CABLE
;
; PURPOSE
;  To extract specified variables from a netCDF file for a specified date
;  and time range and write the data to an ASCII file.
; METHOD
;  The output file is given the same name as the input netCDF file but
;  with the extension '.dat'.
;  The start date and time of the data is read from the 'units' attribute
;  of the 'time' variable.
;  Start and end date and times are specified via the IDL command prompt in
;  the form dd/mm/yyyy hh:mm:ss where dd is the day of the month, mm is
;  the month, yyyy is the year, hh is the hour, mm is the minute and ss
;  is the second.  If hh:mm:ss is omitted, hh, mm and ss are set to 0.
; CALLS
;  parsedatetime - parses date/time strings and returns the year, month, day,
;                  hour, minute, second
; AUTHOR: Peter Isaac
; DATE: 03/09/2007
; MODIFICATIONS
;

; Get the input file name and make the output file name from it.  The
; (IDL session) environment variable InFilePath is checked, if it is
; not empty, the string it contains is used as the default path for
; the input file.  The path to the input file chosen by the user is
; saved to InFilePath.
InFilePath=getenv('InFilePath')
if strlen(InFilePath) eq 0 then $
 InFileName=Dialog_PickFile(FILTER='*.nc',GET_PATH=InFilePath) $
else $
 InFileName=Dialog_PickFile(PATH=InFilePath,FILTER='*.nc',GET_PATH=InFilePath)
BaseName=strmid(InFileName,strlen(InFilePath))
BaseName=strmid(BaseName,0,strpos(BaseName,'.nc'))
setenv, 'InFilePath='+InFilePath
DatFileName=InFilePath+'\'+BaseName+'.dat'

; Open the netCDF file.
ncid=ncdf_open(InFileName)
inqS=ncdf_inquire(ncid)
VarNames=strarr(inqS.nvars)

; Get a free logical unit number and open the output file.
get_lun,DatLUN
openw,DatLUN, DatFileName

; Get the time from the file and convert from seconds elapsed since
; the start date and time to year, month, day, hour, minute and
; second.
SecsID=ncdf_varid(ncid,'time')
ncdf_varget, ncid, SecsID, Seconds
NRec=size(Seconds,/n_elements)
Days=Seconds/86400.0
ncdf_attget, ncid, SecsID, 'units', AttValue
SubStrings=strsplit(string(AttValue),' ',/extract)
StartDate=SubStrings[2]
StartTime=SubStrings[3]
SubStrings=strsplit(StartDate,'-',/extract)
SYear=fix(SubStrings[0])
SMonth=fix(SubStrings[1])
SDay=fix(SubStrings[2])
SubStrings=strsplit(StartTime,':',/extract)
SHour=fix(SubStrings[0])
SMinute=fix(SubStrings[1])
SSecond=fix(SubStrings[2])
SJDay=julday(SMonth,SDay,SYear,SHour,SMinute,SSecond)
JDay=double(SJDay)+double(Days)
caldat,JDay,Month,Day,Year,Hour,Minute,Second

; Tell the user when the data starts, when it finishes and ask
; them for the date/time range to output.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[NRec-1],format='(I2.2)')+'/'+string(Month[NRec-1],format='(I2.2)')+'/'+string(Year[NRec-1],format='(I4)')
EndTime=string(Hour[NRec-1],format='(I2.2)')+':'+string(Minute[NRec-1],format='(I2.2)')+':'+string(Second[NRec-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; Get the start date and time.
SDT: s=''
read, s, prompt='Enter start date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(s, SYear, SMonth, SDay, SHour, SMinute, SSecond)
if (result eq 0) then goto, SDT
; Now get the Julian day of the start date and time.
SJDay=julday(SMonth,SDay,SYear,SHour,SMinute,SSecond)

; Get the end date and time.
EDT: s=''
read, s, prompt='Enter end date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(s, EYear, EMonth, EDay, EHour, EMinute, ESecond)
if (result eq 0) then goto, EDT
; Now get the Julian day of the end date and time ...
EJDay=julday(EMonth,EDay,EYear,EHour,EMinute,ESecond)
; ... and an index of all data between the start and end date and times.
Index=where(JDay ge SJDay and JDay lt EJDay, count)
if (count eq 0) then begin
 print, 'No data between start and end times'
 stop
 endif

; Get a list of variables to extract from the netCDF file.
VarList=''
read, VarList, prompt='Enter variables to extract (comma separated): '
VarList=strcompress(VarList,/remove_all)
Var2Extract=strsplit(VarList,',',/extract,count=Num2Extract)
; Check to see if the variables exist in the file.
NVar=0
j=0
for i=0,Num2Extract-1 do begin
 VarID=ncdf_varid(ncid,Var2Extract[i])
 if (VarID ne -1) then begin
  NVar=NVar+1
  VarNames[j]=Var2Extract[i]
  j=j+1
  endif else begin
   print, ' Variable ',Var2Extract[i],' does not exist in file'
   endelse
   endfor
Data=make_array(NVar,NRec,/float)
Header=make_array(NVar,/string)
for i=0,NVar-1 do begin
 VarID=ncdf_varid(ncid,VarNames[i])
 ncdf_varget, ncid, VarID, VarValue
 Data[i,*]=float(VarValue)
 Header[i]=VarNames[i]
 if (i eq 0) then FmtStrG='G12.4' else FmtStrG=FmtStrG+',G12.4'
 if (i eq 0) then FmtStrA='A12' else FmtStrA=FmtStrA+',A12'
 endfor

; Write the data to file.
FmtStr='(A,'+FmtStrA+')'
printf, DatLUN,'  Yr Mo Dy Hr Mi Sc',Header[*],format=FmtStr
FmtStr='(I4,5(1X,I2),'+FmtStrG+')'
NEle=size(Index,/n_elements)
for i=Index[0], Index[NEle-1] do begin
 printf, DatLUN, Year[i], Month[i], Day[i], Hour[i], Minute[i], Second[i],$
  Data[*,i], $
  format=FmtStr
 endfor

; Close the output file, free up the logical unit number and close
; the netCDF file.
close, DatLUN
free_lun, DatLUN
ncdf_close, ncid

end