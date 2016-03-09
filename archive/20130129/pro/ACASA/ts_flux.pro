pro ts_flux
; PROJECT: ACASA
;
; PURPOSE
;  To plot time series of the fluxes produced by an ACASA run.
; USE
;  Type 'ts_flux' at the IDL prompt.  The procedure will put up a
;  dialog box to allow the observations and model results file to be chosen.
;  The procedure will then display the start and end date and times of the file
;  and prompts for a start date and time in the format 'dd/mm/yyyy hh:mm:ss'.
;  If only the date part is entered, the time is assumed to be '00:00:00'.
;  Once the start date and time have been entered the procedure prompts
;  for an end time in the same format. When this has been entered, a Postscript
;  file of the plot is produced and a GSview session started to display the
;  plot.  The procedure then asks if the user wishes to continue and
;  produce another time series plot or just quit.
;
;  The Postscript files are named:
;   plots\Flux_SYYYMMDDToEYYYMMDD.eps
;  where SYYYMMDD is the start date and EYYYMMDD is the end date of the
;  time series plot.
; METHOD
;  RTSC at this time.
;
; ASSUMPTIONS
;  1) This procedure assumes the following subdirectory structure:
;       <Site1>              ! eg HowardSprings
;        |
;        |- <run>            ! eg HowardSprings\Run001
;        |    |
;        |    |- <Plots>     ! eg HowardSprings\Run001\Plots
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

; *** Get the input file name and make the output file name from it.  The
; *** (IDL session) environment variable ObsFilePath is checked, if it is
; *** not empty, the string it contains is used as the default path for
; *** the input file.  The path to the input file chosen by the user is
; *** saved to ObsFilePath.
ObsFilePath=getenv('ObsFilePath')
if strlen(ObsFilePath) eq 0 then $
 ObsFileName=Dialog_PickFile(TITLE='Select the observations file',GET_PATH=ObsFilePath) $
else $
 ObsFileName=Dialog_PickFile(TITLE='Select the observations file',PATH=ObsFilePath,GET_PATH=ObsFilePath)
if (strlen(ObsFileName) eq 0) then goto, finish
setenv, 'ObsFilePath='+ObsFilePath
; *** Now get the model results file name etc.
ModFilePath=getenv('ModFilePath')
if strlen(ModFilePath) eq 0 then $
 ModFileName=Dialog_PickFile(TITLE='Select the model results file',GET_PATH=ModFilePath) $
else $
 ModFileName=Dialog_PickFile(TITLE='Select the model results file',PATH=ModFilePath,GET_PATH=ModFilePath)
if (strlen(ModFileName) eq 0) then goto, finish
setenv, 'ModFilePath='+ModFilePath
; *** Get the path to the plot subdirectory.
PltPath=ModFilePath+'plots\'

; *** Open the observations file and get the number of lines in the file.
openr,ObsLUN,ObsFileName,/get_lun
nLines=numlines(ObsLUN)
Header=''
readf,ObsLUN,Header
nRecs_obs=nLines-1               ; One header line in the observations file
; *** Declare the arrays to hold the observed data.
xday_obs=make_array(nRecs_obs,/double)
var1=double(0.0)
Fsd_obs=make_array(nRecs_obs,/float)
Fld_obs=make_array(nRecs_obs,/float)
Fn_obs=make_array(nRecs_obs,/float)
Fe_obs=make_array(nRecs_obs,/float)
Fh_obs=make_array(nRecs_obs,/float)
Fc_obs=make_array(nRecs_obs,/float)
Sws10_obs=make_array(nRecs_obs,/float)
Year_obs=make_array(nRecs_obs,/float)
; *** Read the data from the observations file.
for i=0,nRecs_obs-1 do begin
 readf,ObsLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15
 xday_obs[i]=var1
 Fsd_obs[i]=var5
 Fld_obs[i]=var6
 Fn_obs[i]=var10
 Fe_obs[i]=var11
 Fh_obs[i]=var12
 Fc_obs[i]=var13
 Sws10_obs[i]=var14
endfor
; *** Close the observations file.
free_lun, ObsLUN
; *** Generate a series for the year.
Year_obs[0]=BaseYear
for i=1,nRecs_obs-1 do begin
 if xday_obs[i] gt xday_obs[i-1] then Year_obs[i]=Year_obs[i-1] else Year_obs[i]=Year_obs[i-1]+1
endfor

; *** Open the model results file and get the number of lines in the file.
openr,ModLUN,ModFileName,/get_lun
nLines=numlines(ModLUN)
Header=''
nRecs_mod=nLines
for i=0,0 do begin
 readf,ModLUN,Header
 nRecs_mod=nRecs_mod-1               ; One header line in the model results file
endfor
; *** Check to make sure we have the same number of records in the observations
; *** model results files.
;if nRecs_obs ne nRecs_mod then begin
; print,'nRecs_obs (',nRecs_obs,') and nRecs_mod (',nRecs_mod,') are not equal'
; stop
;endif
; *** Declare the arrays to hold the model results.
xday_mod=make_array(nRecs_mod,/double)
var1=double(0.0)
Fn_mod=make_array(nRecs_mod,/float)
Fe_mod=make_array(nRecs_mod,/float)
Fh_mod=make_array(nRecs_mod,/float)
Fc_mod=make_array(nRecs_mod,/float)
Sws_mod=make_array(nRecs_mod,/float)
Year_mod=make_array(nRecs_mod,/float)
; *** Read the data from the model results file.
for i=0,nRecs_mod-1 do begin
 readf,ModLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15,var16,var17,var18,var19,var20,var21,var22
 xday_mod[i]=var1
 Fn_mod[i]=var2
 Fh_mod[i]=var9
 Fe_mod[i]=var10
 Sws_mod[i]=var14
 Fc_mod[i]=var16
endfor
; *** Close the observations file.
free_lun, ModLUN
; *** Generate a series for the year.
Year_mod[0]=BaseYear
for i=1,nRecs_mod-1 do begin
 if xday_mod[i] gt xday_mod[i-1] then Year_mod[i]=Year_mod[i-1] else Year_mod[i]=Year_mod[i-1]+1
endfor
; *** Check to see that we have data at the same times.
; *** Need to work with Julian day to avoid problems with 365/0 discontinuity
; *** when the year changes.
SJDay=julday(1,1,Year_obs,0,0,0)
JDay_obs=double(SJDay)+double(xday_obs)        ; Use of double may be redundant
SJDay=julday(1,1,Year_mod,0,0,0)
JDay_mod=double(SJDay)+double(xday_mod)        ; Use of double may be redundant
; ***  First we get the times when there is data for both observations and model results.
SDay=max([JDay_obs[0],JDay_mod[0]])
EDay=min([JDay_obs[nRecs_obs-1],JDay_mod[nRecs_mod-1]])
Index_obs=where(JDay_obs ge SDay and JDay_obs le EDay, count_obs)
if count_obs eq 0 then begin
 print,'No observations between start (',SDay,') and end (',EDay,') times'
 stop
endif
Index_mod=where(JDay_mod ge SDay and JDay_mod le EDay, count_mod)
if count_mod eq 0 then begin
 print,'No model results between start (',SDay,') and end (',EDay,') times'
 stop
endif
if count_obs ne count_mod then begin
 print,'Number of observations (',count_obs,') and model results (',count_mod,') not equal'
 stop
endif
; *** Get the data between the start and end times.
xday_obs=xday_obs[Index_obs]
Year_obs=Year_obs[Index_obs]
Fsd_obs=Fsd_obs[Index_obs]
Fld_obs=Fld_obs[Index_obs]
Fn_obs=Fn_obs[Index_obs]
Fe_obs=Fe_obs[Index_obs]
Fh_obs=Fh_obs[Index_obs]
Fc_obs=Fc_obs[Index_obs]
Sws10_obs=Sws10_obs[Index_obs]
xday_mod=xday_mod[Index_mod]
Year_mod=Year_mod[Index_mod]
Fn_mod=Fn_mod[Index_mod]
Fe_mod=Fe_mod[Index_mod]
Fh_mod=Fh_mod[Index_mod]
Fc_mod=Fc_mod[Index_mod]
Sws_mod=Sws_mod[Index_mod]
; *** Now get the data for the same times.
diff=xday_obs-xday_mod
Index=where(diff lt 0.000001,count)
if count lt fix(0.95*nRecs_obs) then begin
 print,'Times in obs and model results are not equal for >5% of records'
 stop
endif
xday=xday_obs[Index]
Year=Year_obs[Index]
Fsd_obs=Fsd_obs[Index]
Fld_obs=Fld_obs[Index]
Fn_obs=Fn_obs[Index]
Fe_obs=Fe_obs[Index]
Fh_obs=Fh_obs[Index]
Fc_obs=Fc_obs[Index]
Sws10_obs=Sws10_obs[Index]
Fn_mod=Fn_mod[Index]
Fe_mod=Fe_mod[Index]
Fh_mod=Fh_mod[Index]
Fc_mod=Fc_mod[Index]
Sws_mod=Sws_mod[Index]
; *** Get series of the month, day of the month, hour, minute and second.
SJDay=julday(1,1,Year,0,0,0)
JDay=double(SJDay)+double(xday)        ; Use of double may be redundant
caldat,JDay,Month,Day,Year,Hour,Minute,Second
nRecs=nele(Year)

; *** Tell the user when the data starts, when it finishes and ask
; *** them for the date/time range to output.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[nRecs-1],format='(I2.2)')+'/'+string(Month[nRecs-1],format='(I2.2)')+'/'+string(Year[nRecs-1],format='(I4)')
EndTime=string(Hour[nRecs-1],format='(I2.2)')+':'+string(Minute[nRecs-1],format='(I2.2)')+':'+string(Second[nRecs-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; *** Set up the height of the Y axis.
NPlt=6
YHeight=(1.0-(MarginB+MarginT))/NPlt

; *** Loop back to here for another plot.
nuther1:

; *** Ask the user for the start date and time for this plot.
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

; *** Ask the user for the end date and time for this plot.
EDT: EndDate=''
read, EndDate, prompt='Enter end date and time (as dd/mm/yyyy hh:mm:ss): '
result=parsedatetime(EndDate, EYear, EMonth, EDay, EHour, EMinute, ESecond)
if (result eq 0) then goto, EDT
EJDay=julday(EMonth,EDay,EYear,EHour,EMinute,ESecond)

; *** Get the index of all data between the start and end date and times.
Index=where(JDay ge SJDay and JDay lt EJDay, count)
if (count eq 0) then begin
 print, 'No data between start and end times'
 goto, SDT
 endif

; *** Get the filename for the Postscript file.
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
PSFileName=PltPath+'Flux_'+SDate+'To'+EDate+'.eps'

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
PltNo=1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Fsd_obs[Index],Fld_obs[Index]])
YMax=max([Fsd_obs[Index],Fld_obs[Index]])
plot, X, Fsd_obs[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='label_date', xthick=thk, $
 ytitle='(W/m2)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Fld_obs[Index], thick=thk, color=ct.red
xyouts,XPosBL+0.01,YPosTR-0.02,'Shortwave (black)', /normal, color=ct.black, charthick=thk
xyouts,XPosBL+0.20,YPosTR-0.02,'Longwave (red)', /normal, color=ct.red, charthick=thk
PltNo=2
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Fe_obs[Index],Fe_mod[Index]])
YMax=max([Fe_obs[Index],Fe_mod[Index]])
plot, X, Fe_obs[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Fe (W/m2)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Fe_mod[Index], thick=thk, color=ct.red
PltNo=3
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Fh_obs[Index],Fh_mod[Index]])
YMax=max([Fh_obs[Index],Fh_mod[Index]])
plot, X, Fh_obs[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Fh (W/m2)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Fh_mod[Index], thick=thk, color=ct.red
PltNo=4
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Fc_obs[Index],Fc_mod[Index]])
YMax=max([Fc_obs[Index],Fc_mod[Index]])
plot, X, Fc_obs[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Fc (umol)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Fc_mod[Index], thick=thk, color=ct.red
PltNo=5
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Fn_obs[Index],Fn_mod[Index]])
YMax=max([Fn_obs[Index],Fn_mod[Index]])
plot, X, Fn_obs[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='Fn (W/m2)', ythick=thk, /ynozero
oplot, X, Fn_mod[Index], thick=thk, color=ct.red
PltNo=6
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([Sws_mod[Index],Sws10_obs[Index]])
YMax=max([Sws_mod[Index],Sws10_obs[Index]])
plot, X, Sws_mod[Index], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='SM (m3/m3)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Sws10_obs[Index], thick=thk, color=ct.orange
TitleString='ACASA: Fluxes for '+Site+' ; '+StartDate+' to '+Enddate
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