pro ts_flux
; PROJECT: CABLE
;
; PURPOSE
;  To plot time series of the fluxes produced by CABLE run.
; USE
;  Type 'ts_force' at the IDL prompt.  The procedure will put up a
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
;  3) The input meteorology file is assumed to be a netCDF file that follows
;     the standard conventions adopted for CABLE with regard to variable names
;     and units.
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

; *** Set the site.
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
; *** saved to InFilePath.
ObsFilePath=getenv('ObsFilePath')
if strlen(ObsFilePath) eq 0 then $
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',FILTER='*.nc',GET_PATH=ObsFilePath) $
else $
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',PATH=ObsFilePath,FILTER='*.nc',GET_PATH=ObsFilePath)
if (strlen(ObsFileName) eq 0) then goto, finish
setenv, 'ObsFilePath='+ObsFilePath
; *** Now get the model results file name etc.
ModFilePath=getenv('ModFilePath')
if strlen(ModFilePath) eq 0 then $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',FILTER='*.nc',GET_PATH=ModFilePath) $
else $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',PATH=ModFilePath,FILTER='*.nc',GET_PATH=ModFilePath)
if (strlen(ModFileName) eq 0) then goto, finish
setenv, 'ModFilePath='+ModFilePath
; *** Get the path to the plot subdirectory.
PltPath=ModFilePath+'plots\'

; *** Open the observations amd model results files.
ncid_obs=ncdf_open(ObsFileName)
ncid_mod=ncdf_open(ModFileName)

; *** Get the time from the file and convert from seconds elapsed since
; *** the start date and time to year, month, day, hour, minute and
; *** second.
SecsID=ncdf_varid(ncid_obs,'time')
ncdf_varget, ncid_obs, SecsID, Seconds
NRec=size(Seconds,/n_elements)
Days=Seconds/86400.0
ncdf_attget, ncid_obs, SecsID, 'units', AttValue
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

; *** Tell the user when the data starts and when it finishes.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[NRec-1],format='(I2.2)')+'/'+string(Month[NRec-1],format='(I2.2)')+'/'+string(Year[NRec-1],format='(I4)')
EndTime=string(Hour[NRec-1],format='(I2.2)')+':'+string(Minute[NRec-1],format='(I2.2)')+':'+string(Second[NRec-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; *** Get the variables from the observations file.
ObsList='SWdown,LWdown,Fe,Qle,Fh,Qh,Fc,NEE,Fn,Rnet,Sws10'
ObsList=strcompress(ObsList,/remove_all)
ObsNames=strsplit(ObsList,',',/extract,count=NObs)
for i=0,NObs-1 do begin
 VarID_obs=ncdf_varid(ncid_obs,ObsNames[i])
 if (VarID_obs ne -1) then begin
  case ObsNames[i] of
   'SWdown': ncdf_varget, ncid_obs, VarID_obs, Fsd_obs
   'LWdown': ncdf_varget, ncid_obs, VarID_obs, Fld_obs
   'Fe'    : ncdf_varget, ncid_obs, VarID_obs, Fe_obs
   'Qle'   : ncdf_varget, ncid_obs, VarID_obs, Fe_obs
   'Fh'    : ncdf_varget, ncid_obs, VarID_obs, Fh_obs
   'Qh'    : ncdf_varget, ncid_obs, VarID_obs, Fh_obs
   'Fc'    : ncdf_varget, ncid_obs, VarID_obs, Fc_obs
   'NEE'   : ncdf_varget, ncid_obs, VarID_obs, Fc_obs
   'Fn'    : ncdf_varget, ncid_obs, VarID_obs, Fn_obs
   'Rnet'  : ncdf_varget, ncid_obs, VarID_obs, Fn_obs
   'Sws10' : ncdf_varget, ncid_obs, VarID_obs, Sws10_obs
   else    : print,ObsNames[i]+' not matched in observations file'
  endcase
 endif else begin
  print, ObsNames[i]+' does not exist in observations file'
 endelse
endfor

Fc_obs=1000.*Fc_obs/44.

; *** Get the variables from the model results file.
ModList='Qle,Qh,NEE,SWnet,LWnet,SoilMoist'
ModList=strcompress(ModList,/remove_all)
ModNames=strsplit(ModList,',',/extract,count=NMod)
for i=0,NMod-1 do begin
 VarID_mod=ncdf_varid(ncid_mod,ModNames[i])
 if (VarID_mod ne -1) then begin
  case ModNames[i] of
   'Qle'   : ncdf_varget, ncid_mod, VarID_mod, Fe_mod
   'Qh'    : ncdf_varget, ncid_mod, VarID_mod, Fh_mod
   'NEE'   : ncdf_varget, ncid_mod, VarID_mod, Fc_mod
   'SWnet' : ncdf_varget, ncid_mod, VarID_mod, Fsn_mod
   'LWnet' : ncdf_varget, ncid_mod, VarID_mod, Fln_mod
   'SoilMoist' : begin
    ncdf_varget, ncid_mod, VarID_mod, Sws_mod
    ThisID=ncdf_varid(ncid_mod,'zse')
    ncdf_varget, ncid_mod, ThisID, zse
    Sws0_mod=Sws_mod[0,0,0,*]/zse[0,0,0]/1000.
    Sws1_mod=Sws_mod[0,0,1,*]/zse[0,0,1]/1000.
    Sws2_mod=Sws_mod[0,0,2,*]/zse[0,0,2]/1000.
    Sws3_mod=Sws_mod[0,0,3,*]/zse[0,0,3]/1000.
    Sws4_mod=Sws_mod[0,0,4,*]/zse[0,0,4]/1000.
    Sws5_mod=Sws_mod[0,0,5,*]/zse[0,0,5]/1000.
    end
   else    : print,ModNames[i]+' not matched in model results file'
  endcase
 endif
endfor
Fn_mod=Fsn_mod+Fln_mod

; *** Close the netCDF files.
ncdf_close, ncid_obs
ncdf_close, ncid_mod

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

; Start plotting.
; Subtract the first element of JDay so that the X axis series starts
; at 0 and not ~2.4E6.  This is necessary to work around the limitation
; of IDL versions prior to V6 where PLOT converted the X and Y data
; series to single precision before plotting.  Single precision is not
; sufficient to correctly handle time information in the Julian date.
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
YMin=min([Sws1_mod[Index],Sws2_mod[Index],Sws3_mod[Index],Sws10_obs[Index]])
YMax=max([Sws1_mod[Index],Sws2_mod[Index],Sws3_mod[Index],Sws10_obs[Index]])
plot, X, Sws1_mod[Index], thick=thk, /nodata, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=thk, $
 ytitle='SM (m3/m3)', yrange=[YMin,YMax], ythick=thk, /ynozero
oplot, X, Sws0_mod[Index], thick=thk, color=ct.green
oplot, X, Sws1_mod[Index], thick=thk, color=ct.red
oplot, X, Sws2_mod[Index], thick=thk, color=ct.orange
oplot, X, Sws3_mod[Index], thick=thk, color=ct.blue
oplot, X, Sws10_obs[Index], thick=thk, color=ct.black
Str=string(zse[0],format='(F5.3)')
xyouts,XPosBL+0.01,YPosTR-0.02,Str, /normal, color=ct.green, charthick=thk
Str=string(zse[1],format='(F5.3)')
xyouts,XPosBL+0.15,YPosTR-0.02,Str, /normal, color=ct.red, charthick=thk
Str=string(zse[2],format='(F5.3)')
xyouts,XPosBL+0.30,YPosTR-0.02,Str, /normal, color=ct.orange, charthick=thk
Str=string(zse[3],format='(F5.3)')
xyouts,XPosBL+0.45,YPosTR-0.02,Str, /normal, color=ct.blue, charthick=thk
;oplot, X, SM3_mod[Index], thick=thk, color=ct.yellow
;oplot, X, SM4_mod[Index], thick=thk, color=ct.green
;oplot, X, SM5_mod[Index], thick=thk, color=ct.blue
TitleString='CABLE: Fluxes for '+Site+' ; '+StartDate+' to '+Enddate
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