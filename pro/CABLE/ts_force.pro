pro ts_force
; PROJECT: CABLE
;
; PURPOSE
;  To plot time series of the forcing meteorology used for a CABLE run.
; USE
;  Type 'timeseries_force' at the IDL prompt.  The procedure will put up a
;  dialog box to allow the met file (netCDF) to be chosen, it will then
;  display the start and end date and times of the file.  The procedure
;  then prompts for a start date and time in the format 'dd/mm/yyyy hh:mm:ss'.
;  If only the date part is entered, the time is assumed to be '00:00:00'.
;  Once the start date and time have been entered the procedure prompts
;  for an end time in the same format.  When this has been entered a Postscript
;  file of the plot is produced and a GSview session started to display the
;  plot.  The procedure then asks if the user wishes to continue and
;  produce another time series plot or just quit.
;
;  The Postscript files are named:
;   plots\<BaseName>_SYYYMMDDToEYYYMMDD.eps
;  where SYYYMMDD is the start date and EYYYMMDD is the end date of the
;  time series plot.
; METHOD
;  RTSC at this time.
;
; ASSUMPTIONS
;  1) This procedure assumes there is a subdirectory 'plots\' in the directory
;     containing the input file.  The postscript plot files are placed there.
;  2) This procedure assumes that Ghostscript and GSView are installed, that
;     the 32-bit version of GSview is being used (gsview32.exe) and that the
;     PATH environment variable contains the GSview location.
;  3) The input meteorology file is assumed to be a netCDF file that follows
;     the standard conventions adopted for CABLE with regard to variable names
;     and units.
;  4) Some of the routines used are not available in versions of IDL prior to V6.0
; SIDE EFFECTS
;  The pre-defined colour table 39 is loaded, the colour table in use before
;  this procedure is run is not restored.
; CALLS
;  parsedatetime
;   - parses date/time strings and returns the year, month, day,
;     hour, minute, second
;  definecolours_ct39
;   - defines an anonymous structure called ct that contains
;     the indices for the primary colours in colour table 39
;     (Rainbow+white).
; AUTHOR: Peter Isaac (SGES, Monash University)
; DATE: 03/09/2007
; MODIFICATIONS
;

; Set the margins between the plot region and the plot-data window.  The
; plot region is defined in terms of "normal" coordinates ie the bottom
; left corner has coordinates (0,0) and the top right corner has coordinates
; (1,1).
MarginB=0.075      ; bottom margin
MarginL=0.075      ; left margin
MarginT=0.075      ; top margin
MarginR=0.025      ; right margin
XWidth=(1.0-(MarginL+MarginR))         ; Width of the X axis
XPosBL=MarginL
XPosTR=1.0-MarginR

; Get the input file name and make the output file name from it.  The
; (IDL session) environment variable InFilePath is checked, if it is
; not empty, the string it contains is used as the default path for
; the input file.  The path to the input file chosen by the user is
; saved to InFilePath.
InFilePath=getenv('InFilePath')
if strlen(InFilePath) eq 0 then $
 InFileName=Dialog_PickFile(TITLE='Select meteorology file',FILTER='*.nc',GET_PATH=InFilePath) $
else $
 InFileName=Dialog_PickFile(TITLE='Select meteorology file',PATH=InFilePath,FILTER='*.nc',GET_PATH=InFilePath)
if (strlen(InFileName) eq 0) then goto, finish
setenv, 'InFilePath='+InFilePath
; Get the base name of the input file.
PathLen=strlen(InFilePath)
DotPos=rstrpos(InFileName,'.')
BaseName = strmid(InFileName, PathLen, DotPos-PathLen)
; *** Get the path to the plot subdirectory.
s1=strpos(strlowcase(InFilePath),'data')
PltPath=strmid(InFilePath,0,s1)+'plots\'

; Open the netCDF file.
ncid=ncdf_open(InFileName)
inqS=ncdf_inquire(ncid)
VarNames=strarr(inqS.nvars)

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

; Get a list of variables to extract from the netCDF file.
VarList='SWdown,LWdown,Tair,Qair,Rainf,Snowf,PSurf,Wind,CO2air'
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

; Get the data out of the netCDF file and into appropriately named
; variables.  NPlt is the number of plots to be done, this may be less
; than the number of variables because some plots contain two or more
; sets of data.
NPlt=0
for i=0,NVar-1 do begin
 VarID=ncdf_varid(ncid,VarNames[i])
 case VarNames[i] of
  'SWdown': begin
   ncdf_varget, ncid, VarID, Sdn
   NPlt=NPlt+1
   end
  'LWdown': begin
   ncdf_varget, ncid, VarID, Ldn
   end
  'Tair':   begin
   ncdf_varget, ncid, VarID, Ta
   ncdf_attget, ncid, VarID, 'units', AttValue
   if (strupcase(AttValue) eq 'K') then Ta=Ta-273.2
   NPlt=NPlt+1
   end
  'Qair':   begin
   ncdf_varget, ncid, VarID, q
   ncdf_attget, ncid, VarID, 'units', AttValue
   if (strupcase(AttValue) eq 'KG/KG') then q=q*1000.0
   NPlt=NPlt+1
   end
  'Rainf':  begin
   ncdf_varget, ncid, VarID, Rf
   Rf = Rf*3600.0
   NPlt=NPlt+1
   end
  'Snowf':  begin
   ncdf_varget, ncid, VarID, Sf
   Sf = Sf*3600.0
   end
  'PSurf':  begin
   ncdf_varget, ncid, VarID, ps
   ncdf_attget, ncid, VarID, 'units', AttValue
   if (strupcase(AttValue) eq 'PA') then ps=ps/100
   NPlt=NPlt+1
   end
  'Wind':   begin
   ncdf_varget, ncid, VarID, WS
   NPlt=NPlt+1
   end
  'CO2air': begin
   ncdf_varget, ncid, VarID, CO2a
   NPlt=NPlt+1
   end
  endcase
  endfor

; Get the specific humidity deficit.
Dq=qs(Ta,ps)*1000.-q

; Close the netCDF file.
ncdf_close, ncid

; Set up the height of the Y axis.
YHeight=(1.0-(MarginB+MarginT))/NPlt

; Loop back to here for another plot.
nuther1:

; Get the start date and time.
SDT: StartDate=''
read, StartDate, prompt='Enter start date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(StartDate, SYear, SMonth, SDay, SHour, SMinute, SSecond)
if (result eq 0) then goto, SDT
SJDay=julday(SMonth,SDay,SYear,SHour,SMinute,SSecond)

; Set up the X axis label format for day of the month.  We use an offset
; as a work-around for the single precision limit of PLOT in IDL versions
; prior to V6.
SJDate=julday(SMonth,SDay,SYear)
dummy=label_date(date_format='%D/%N/%Y',offset=SJDate)

; Get the end date and time.
EDT: EndDate=''
read, EndDate, prompt='Enter end date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(EndDate, EYear, EMonth, EDay, EHour, EMinute, ESecond)
if (result eq 0) then goto, EDT
EJDay=julday(EMonth,EDay,EYear,EHour,EMinute,ESecond)

; ... and an index of all data between the start and end date and times.
Index=where(JDay ge SJDay and JDay lt EJDay, count)
if (count eq 0) then begin
 print, 'No data between start and end times'
 goto, SDT
 endif

; Get the filename for the Postscript file.
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
;PSFileName=PltPath+BaseName+'_Force_'+SDate+'To'+EDate+'.eps'
PSFileName=PltPath+'Force_'+SDate+'To'+EDate+'.eps'

; Set up the Postscript device.
set_plot,'ps'
device, filename=PSFileName, /encapsulated, $
 xsize=29.7, ysize=21.0, bits=8, /color
thk=4              ; thickness scale factor for lines and fonts in Postscript output

; Set up the colours.  We will use the built-in "Rainbow+white"
; colour table.  The primary colours are returned in the structure ct.
definecolours_ct39, ct

; Start plotting.
; Subtract the first element of JDay so that the X axis series starts
; at 0 and not ~2.4E6.  This is necessary to work around the limitation
; of IDL versions prior to V6 where PLOT converted the X and Y data
; series to single precision before plotting.  Single precision is not
; sufficient to correctly handle time information in the Julian date.
X=JDay[Index]-JDay[Index[0]]
XMax=max(X)
XMin=min(X)
n=1
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, Sdn[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xtitle='Date', xstyle=1, xrange=[XMin,XMax], xtickformat='label_date', xthick=thk, $
 ytitle='(W/m^2)', ythick=thk, /ynozero
oplot, X, Ldn[Index], thick=thk, color=ct.red
xyouts,XPosBL+0.01,YPosTR-0.02,'Shortwave (black)', /normal, color=ct.black, charthick=thk
xyouts,XPosBL+0.20,YPosTR-0.02,'Longwave (red)', /normal, color=ct.red, charthick=thk
n=2
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, Ta[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Ta (C)', ythick=thk, /ynozero
n=3
YMin=min([Dq[Index],q[Index]])
YMax=max([Dq[Index],q[Index]])
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, Dq[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Dq (g/kg)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, q[Index], thick=thk, color=ct.red
xyouts,XPosBL+0.01,YPosTR-0.02,'Dq (black)', /normal, color=ct.black, charthick=thk
xyouts,XPosBL+0.20,YPosTR-0.02,'q (red)', /normal, color=ct.red, charthick=thk
n=4
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, WS[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='WS (m/s)', ythick=thk, /ynozero
n=5
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, ps[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='ps (hPa)', ythick=thk, /ynozero
n=6
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, Rf[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='(mm)', ythick=thk, /ynozero
oplot, X, Sf[Index], thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Rainfall (black)', /normal, color=ct.black, charthick=thk
xyouts,XPosBL+0.20,YPosTR-0.02,'Snowfall (blue)', /normal, color=ct.blue, charthick=thk
if (size(CO2a,/N_ELEMENTS) ne 0) then begin
 n=7
 YPosBL=MarginB+(n-1)*YHeight
 YPosTR=YPosBL+YHeight-0.01
 plot, X, CO2a[Index], thick=thk, $
  position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
  xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
  ytitle='CO2 (ppm)', ythick=thk, /ynozero
endif
TitleString='CABLE: Forcing meteorology for '+BaseName+' ; '+StartDate+' to '+Enddate
xyouts,0.5, 0.95, alignment=0.5, TitleString, /normal, charthick=thk

; Close the Postscript file and view it in GSview.
device, /close
if (!version.release ge 6) then $
 spawn,'gsview32 '+PSFileName, /nowait, /noshell $
else $
 spawn,'gsview32 '+PSFileName, /noshell

; Check to see if the user wants another plot.
Answer=''
read, Answer, prompt='[C]ontinue or [Q]uit? '
if (strupcase(Answer) eq 'C') then goto, nuther1 else goto, finish

finish:
set_plot,'win'

end