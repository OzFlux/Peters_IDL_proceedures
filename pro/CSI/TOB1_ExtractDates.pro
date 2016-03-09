pro TOB1_ExtractDates

InFile='e:\spofatte\sites\adelaideriver\data\raw\tob1_cr3000_ad_river_01_feb_2008_flux.dat'
InFilePath = strmid(InFile,0,rstrpos(InFile,'\'))
tob1info,InFile,SSecs,ESecs

jdcnv, 1990, 1, 1, 0, ZJDay
SDays = double(SSecs)/double(86400.0)
JDay = ZJDay + SDays + 5.787E-6
caldat, JDay, SMonth, SDay, SYear, SHour, SMinute, SSecond
SDateTime = string(SDay,'/',SMonth,'/',SYear,' ',SHour,':',SMinute,':',SSecond, $
                   format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
EDays = double(ESecs)/double(86400.0)
JDay = ZJDay + EDays + 5.787E-6
caldat, JDay, EMonth, EDay, EYear, EHour, EMinute, ESecond
EDateTime = string(EDay,'/',EMonth,'/',EYear,' ',EHour,':',EMinute,':',ESecond, $
                   format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
print, 'File contains data from ', SDateTime, ' to ', EDateTime

; *** Ask the user for the start date and time for this plot.
SDT: StartDate=''
read, StartDate, prompt='Enter start date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(StartDate, SYear, SMonth, SDay, SHour, SMinute, SSecond)
if (result eq 0) then goto, SDT
SJDay=julday(SMonth,SDay,SYear,SHour,SMinute,SSecond)
USSecs = ulong(SJDay-ZJDay)*ulong(86400)
; *** Ask the user for the end date and time for this plot.
EDT: EndDate=''
read, EndDate, prompt='Enter end date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(EndDate, EYear, EMonth, EDay, EHour, EMinute, ESecond)
if (result eq 0) then goto, EDT
EJDay=julday(EMonth,EDay,EYear,EHour,EMinute,ESecond)
UESecs = ulong(EJDay-ZJDay)*ulong(86400)
; *** Read the TOB1 file to get the data between the start and end dates/times.
readtob1,InFile,USSecs,UESecs,Header,Time,Data
TimeSize = size(Time)
NumRecords = TimeSize[2]
; *** Construct the output file name using the input file path and
; *** the start and finish times in the file.
SSecs = Time[0,0]
SDays = double(SSecs)/double(86400.0)
JDay = ZJDay + SDays + 5.787E-6
caldat, JDay, SMonth, SDay, SYear, SHour, SMinute, SSecond
SDateTime = string(SYear,SMonth,SDay,SHour,SMinute,SSecond,FORMAT='(I4.4,5I2.2)')
ESecs = Time[0,NumRecords-1]
EDays = double(ESecs)/double(86400.0)
JDay = ZJDay + EDays + 5.787E-6
caldat, JDay, EMonth, EDay, EYear, EHour, EMinute, ESecond
EDateTime = string(EYear,EMonth,EDay,EHour,EMinute,ESecond,FORMAT='(I4.4,5I2.2)')
OutFileName = SDateTime+'_'+EDateTime+'.TOB1'
OutFile = InFilePath+'\'+OutFileName
; *** Write the header, time and data to a TOB1 file
writetob1,OutFile,Header,Time,Data

end
