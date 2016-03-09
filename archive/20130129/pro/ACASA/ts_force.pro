pro ts_force
; PROJECT: ACASA
;
; PURPOSE
;  To plot time series of the forcing meteorology used for an ACASA run.
; USE
;  Type 'ts_force' at the IDL prompt.  The procedure will put up a
;  dialog box to allow the met file to be chosen, it will then
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
;   plots\Force_SYYYMMDDToEYYYMMDD.eps
;  where SYYYMMDD is the start date and EYYYMMDD is the end date of the
;  time series plot.
; METHOD
;  RTSC at this time.
; ASSUMPTIONS
;  1) This procedure assumes the following subdirectory structure:
;       <Site1>
;        |
;        |- <run>
;        |    |
;        |    |- <Plots>
;        |
;       <Site2>
;  2) This procedure assumes that Ghostscript and GSView are installed, that
;     the 32-bit version of GSview is being used (gsview32.exe) and that the
;     PATH environment variable contains the GSview location.
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
; DATE: 03/11/2007
; MODIFICATIONS
;

; *** The default format observations file for ACASA does not have a field for
; *** the year of the observations.  Here we define the base year and the site.
BaseYear=2004.
Site='Howard Springs'

; *** Set the margins between the plot region and the plot-data window.  The
; *** plot region is defined in terms of "normal" coordinates ie the bottom
; *** left corner has coordinates (0,0) and the top right corner has coordinates
; *** (1,1).
MarginB=0.075      ; bottom margin
MarginL=0.075      ; left margin
MarginT=0.075      ; top margin
MarginR=0.025      ; right margin
XWidth=(1.0-(MarginL+MarginR))         ; Width of the X axis
XPosBL=MarginL
XPosTR=1.0-MarginR

; *** Get the file names of the observations and model results file and
; *** construct the output file name.  The IDL environment variable
; *** ObsFilePath is checked.  If it is not empty, the string it contains
; *** is used as the default path for the observations file.
ObsFilePath=getenv('ObsFilePath')
if strlen(ObsFilePath) eq 0 then $
 ObsFileName=Dialog_PickFile(TITLE='Select meteorology file',GET_PATH=ObsFilePath) $
else $
 ObsFileName=Dialog_PickFile(TITLE='Select meteorology file',PATH=ObsFilePath,GET_PATH=ObsFilePath)
if (strlen(ObsFileName) eq 0) then goto, finish
setenv, 'ObsFilePath='+ObsFilePath
; *** Get the path to the plot subdirectory.
PltPath=ObsFilePath+'plots\'

; *** Open the observations file and get the number of lines in the file.
openr,ObsLUN,ObsFileName,/get_lun
nLines=numlines(ObsLUN)
Header=''
readf,ObsLUN,Header
nRecs=nLines-1               ; One header line in the observations file

; *** Declare the arrays to hold the observed data.
xday=make_array(nRecs,/double)
var1=double(0.0)
Rain=make_array(nRecs,/float)
q=make_array(nRecs,/float)
WS=make_array(nRecs,/float)
Fsd=make_array(nRecs,/float)
Fld=make_array(nRecs,/float)
Ta=make_array(nRecs,/float)
ps=make_array(nRecs,/float)
CO2=make_array(nRecs,/float)
Fn=make_array(nRecs,/float)
Fe=make_array(nRecs,/float)
Fh=make_array(nRecs,/float)
Fc=make_array(nRecs,/float)
Sws10=make_array(nRecs,/float)
Ts10=make_array(nRecs,/float)
Year=make_array(nRecs,/float)
; *** Read the data from the observations file.
for i=0,nRecs-1 do begin
 readf,ObsLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15
 xday[i]=var1
 Rain[i]=var2
 q[i]=var3
 WS[i]=var4
 Fsd[i]=var5
 Fld[i]=var6
 Ta[i]=var7-273.15
 ps[i]=var8
 CO2[i]=var9
 Fn[i]=var10
 Fe[i]=var11
 Fh[i]=var12
 Fc[i]=var13
 Sws10[i]=var14
 Ts10[i]=var15-273.15
endfor

; *** Generate a series for the year.
Year[0]=BaseYear
for i=1,nRecs-1 do begin
 if xday[i] gt xday[i-1] then Year[i]=Year[i-1] else Year[i]=Year[i-1]+1
endfor

; *** Get series of the month, day of the month, hour, minute and second.
SJDay=julday(1,1,Year,0,0,0)
JDay=double(SJDay)+double(xday)        ; Use of double may be redundant
caldat,JDay,Month,Day,Year,Hour,Minute,Second

; *** Tell the user when the data starts, when it finishes and ask
; *** them for the date/time range to output.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[nRecs-1],format='(I2.2)')+'/'+string(Month[nRecs-1],format='(I2.2)')+'/'+string(Year[nRecs-1],format='(I4)')
EndTime=string(Hour[nRecs-1],format='(I2.2)')+':'+string(Minute[nRecs-1],format='(I2.2)')+':'+string(Second[nRecs-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; *** Get the specific humidity deficit.
Dq=qs(Ta,ps)*1000.-q

; *** Set up the height of the Y axis.
NPlt=7
YHeight=(1.0-(MarginB+MarginT))/NPlt

; *** Loop back to here for another plot.
nuther1:

; *** Get the start date and time.
SDT: StartDate=''
read, StartDate, prompt='Enter start date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(StartDate, SYear, SMonth, SDay, SHour, SMinute, SSecond)
if (result eq 0) then goto, SDT
SJDay=julday(SMonth,SDay,SYear,SHour,SMinute,SSecond)

; *** Set up the X axis label format for day of the month.  We use an offset
; *** as a work-around for the single precision limit of PLOT in IDL versions
; *** prior to V6.
SJDate=julday(SMonth,SDay,SYear)
dummy=label_date(date_format='%D/%N/%Y',offset=SJDate)

; *** Get the end date and time.
EDT: EndDate=''
read, EndDate, prompt='Enter end date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(EndDate, EYear, EMonth, EDay, EHour, EMinute, ESecond)
if (result eq 0) then goto, EDT
EJDay=julday(EMonth,EDay,EYear,EHour,EMinute,ESecond)

; *** Get an index of all data between the start and end date and times.
Index=where(JDay ge SJDay and JDay lt EJDay, count)
if (count eq 0) then begin
 print, 'No data between start and end times'
 goto, SDT
 endif

; *** Get the file name for the Postscript file.
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
PSFileName=PltPath+'Force_'+SDate+'To'+EDate+'.eps'

; *** Set up the Postscript device.
set_plot,'ps'
device, filename=PSFileName, /encapsulated, $
 xsize=29.7, ysize=21.0, bits=8, /color
thk=4              ; thickness scale factor for lines and fonts in Postscript output

; *** Set up the colours.  We will use the built-in "Rainbow+white"
; *** colour table.  The primary colours are returned in the structure ct.
definecolours_ct39, ct

; *** Start plotting.
; *** Subtract the first element of JDay so that the X axis series starts
; *** at 0 and not ~2.4E6.  This is necessary to work around the limitation
; *** of IDL versions prior to V6 where PLOT converted the X and Y data
; *** series to single precision before plotting.  Single precision is not
; *** sufficient to correctly handle time information in the Julian date.
X=JDay[Index]-JDay[Index[0]]
XMax=max(X)
XMin=min(X)
n=1
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, Fsd[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xtitle='Date', xstyle=1, xrange=[XMin,XMax], xtickformat='label_date', xthick=thk, $
 ytitle='(W/m^2)', ythick=thk, /ynozero
oplot, X, Fld[Index], thick=thk, color=ct.red
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
plot, X, Rain[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='(mm)', ythick=thk, /ynozero
;oplot, X, Sf[Index], thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Rainfall (black)', /normal, color=ct.black, charthick=thk
;xyouts,XPosBL+0.20,YPosTR-0.02,'Snowfall (blue)', /normal, color=ct.blue, charthick=thk
n=7
YPosBL=MarginB+(n-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
plot, X, CO2[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='CO2 (ppm)', ythick=thk, /ynozero
TitleString='ACASA: Forcing meteorology for '+Site+' ; '+StartDate+' to '+Enddate
xyouts,0.5, 0.95, alignment=0.5, TitleString, /normal, charthick=thk

; *** Close the Postscript file and view it in GSview.
device, /close
if (!version.release ge 6) then $
 spawn,'gsview32 '+PSFileName, /nowait, /noshell $
else $
 spawn,'gsview32 '+PSFileName, /noshell

; *** Check to see if the user wants another plot.
Answer=''
read, Answer, prompt='[C]ontinue or [Q]uit? '
if (strupcase(Answer) eq 'C') then goto, nuther1 else goto, finish

finish:
set_plot,'win'

end