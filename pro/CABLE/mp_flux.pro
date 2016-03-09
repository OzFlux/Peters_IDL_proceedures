pro mp_flux
; PROJECT: CABLE
;
; PURPOSE
;  To plot monthly average values of net radiation, latent heat flux, sensible
;  heat flux and CO2 flux for a 12 month period.
; USE
;  Type 'mp_flux' at the IDL command prompt.  The procedure will put up a
;  dialog box to allow the observations and model results file to be chosen.
;  A Postscript file of the plot of monthly averages is produced and a GSview
;  session started to display the plot.  The monthly averages of Fn, Fe, Fh
;  and Fc for both the observations and model results are also written to
;  an ASCII file.
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
; DATE: 03/09/2007
; MODIFICATIONS
;

; *** Set up site name etc.
Site='Howard Springs'

; *** Set the margins between the plot region and the plot-data window.  The
; *** plot region is defined in terms of "normal" coordinates ie the bottom
; *** left corner has coordinates (0,0) and the top right corner has coordinates
; *** (1,1).
NRows=2
NCols=2
MarginB=0.075      ; bottom margin
MarginL=0.075      ; left margin
MarginT=0.075      ; top margin
MarginR=0.025      ; right margin
YMargin=0.01
XMargin=0.075
PHeight=1.0-(MarginB+MarginT)
PWidth=1.0-(MarginL+MarginR)
YHeight=(PHeight-(NRows-1)*YMargin)/NRows
XWidth=(PWidth-(NCols-1)*XMargin)/NCols

; *** Get the input file name and make the output file name from it.  The
; *** (IDL session) environment variable InFilePath is checked, if it is
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

; *** Open the observations file.
ncid_obs=ncdf_open(ObsFileName)
ncid_mod=ncdf_open(ModFileName)

; *** Get the time from the file and convert from seconds elapsed since
; *** the start date and time to year, month, day, hour, minute and second.
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

; *** Tell the user when the data starts, when it finishes and ask
; *** them for the date/time range to output.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[NRec-1],format='(I2.2)')+'/'+string(Month[NRec-1],format='(I2.2)')+'/'+string(Year[NRec-1],format='(I4)')
EndTime=string(Hour[NRec-1],format='(I2.2)')+':'+string(Minute[NRec-1],format='(I2.2)')+':'+string(Second[NRec-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; *** Get the variables from the observations file.
ObsList='SWdown,LWdown,Fe,Qle,Fh,Qh,Fc,NEE,Fn,Rnet,Sws10,Tsoil,Rainf'
ObsList=strcompress(ObsList,/remove_all)
ObsNames=strsplit(ObsList,',',/extract,count=NObs)
for i=0,NObs-1 do begin
 VarID_obs=ncdf_varid(ncid_obs,ObsNames[i])
 if (VarID_obs ne -1) then begin
  case ObsNames[i] of
   'SWdown': ncdf_varget, ncid_obs, VarID_obs, Sdn_obs
   'LWdown': ncdf_varget, ncid_obs, VarID_obs, Ldn_obs
   'Fe'    : ncdf_varget, ncid_obs, VarID_obs, Fe_obs
   'Qle'   : ncdf_varget, ncid_obs, VarID_obs, Fe_obs
   'Fh'    : ncdf_varget, ncid_obs, VarID_obs, Fh_obs
   'Qh'    : ncdf_varget, ncid_obs, VarID_obs, Fh_obs
   'Fc'    : ncdf_varget, ncid_obs, VarID_obs, Fc_obs
   'NEE'   : ncdf_varget, ncid_obs, VarID_obs, Fc_obs
   'Fn'    : ncdf_varget, ncid_obs, VarID_obs, Fn_obs
   'Rnet'  : ncdf_varget, ncid_obs, VarID_obs, Fn_obs
   'Rainf' : ncdf_varget, ncid_obs, VarID_obs, Rf_obs
   'Sws10' : ncdf_varget, ncid_obs, VarID_obs, Sws_obs
   'Tsoil' : ncdf_varget, ncid_obs, VarID_obs, Ts_obs
   else    : print,ObsNames[i]+' not matched in observations file'
  endcase
 endif else begin
  print, ObsNames[i]+' does not exist in observations file'
 endelse
endfor
Fc_obs=1000.*Fc_obs/44.
Rf_obs=Rf_obs*1800.
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
   'SWnet' : ncdf_varget, ncid_mod, VarID_mod, Fswn_mod
   'LWnet' : ncdf_varget, ncid_mod, VarID_mod, Flwn_mod
   'SoilMoist' : begin
    ncdf_varget, ncid_mod, VarID_mod, SM_mod
    ThisID=ncdf_varid(ncid_mod,'zse')
    ncdf_varget, ncid_mod, ThisID, zse
    Sws0_mod=SM_mod[0,0,0,*]/zse[0,0,0]/1000.
    Sws1_mod=SM_mod[0,0,1,*]/zse[0,0,1]/1000.
    Sws2_mod=SM_mod[0,0,2,*]/zse[0,0,2]/1000.
    Sws3_mod=SM_mod[0,0,3,*]/zse[0,0,3]/1000.
    Sws4_mod=SM_mod[0,0,4,*]/zse[0,0,4]/1000.
    Sws5_mod=SM_mod[0,0,5,*]/zse[0,0,5]/1000.
    end
   else    : print,ModNames[i]+' not matched in model results file'
  endcase
 endif
endfor
Fn_mod=Fswn_mod+Flwn_mod

; *** Close the netCDF files.
ncdf_close, ncid_obs
ncdf_close, ncid_mod

; *** Get the average for each month.
Fn_obs_month=make_array(12,2,/float)
Fn_mod_month=make_array(12,2,/float)
Fe_obs_month=make_array(12,2,/float)
Fe_mod_month=make_array(12,2,/float)
Fh_obs_month=make_array(12,2,/float)
Fh_mod_month=make_array(12,2,/float)
Fc_obs_month=make_array(12,2,/float)
Fc_mod_month=make_array(12,2,/float)
Sws_obs_month=make_array(12,2,/float)
Sws_mod_month=make_array(12,2,/float)
Rf_obs_month=make_array(12,2,/float)
for i=0, 11 do begin
 Index=where(Month eq (i+1),count)
 Fn_obs_month[i,0]=mean(Fn_obs[Index])
 Fn_obs_month[i,1]=stddev(Fn_obs[Index])
 Fn_mod_month[i,0]=mean(Fn_mod[Index])
 Fn_mod_month[i,1]=stddev(Fn_mod[Index])
 Fe_obs_month[i,0]=mean(Fe_obs[Index])
 Fe_obs_month[i,1]=stddev(Fe_obs[Index])
 Fe_mod_month[i,0]=mean(Fe_mod[Index])
 Fe_mod_month[i,1]=stddev(Fe_mod[Index])
 Fh_obs_month[i,0]=mean(Fh_obs[Index])
 Fh_obs_month[i,1]=stddev(Fh_obs[Index])
 Fh_mod_month[i,0]=mean(Fh_mod[Index])
 Fh_mod_month[i,1]=stddev(Fh_mod[Index])
 Fc_obs_month[i,0]=mean(Fc_obs[Index])
 Fc_obs_month[i,1]=stddev(Fc_obs[Index])
 Fc_mod_month[i,0]=mean(Fc_mod[Index])
 Fc_mod_month[i,1]=stddev(Fc_mod[Index])
 Sws_obs_month[i,0]=mean(Sws_obs[Index])
 Sws_obs_month[i,1]=stddev(Sws_obs[Index])
 Sws_mod_month[i,0]=mean(Sws0_mod[Index])
 Sws_mod_month[i,1]=stddev(Sws0_mod[Index])
 Rf_obs_month[i,0]=total(Rf_obs[Index])
endfor

; *** Get the filename for the output file.
SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EYear=Year[NRec-1] & EMonth=Month[NRec-1] & EDay=Day[NRec-1]
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
OutFileName=ModFilePath+'MP_Flux_'+SDate+'To'+EDate+'.dat'

; *** Write the monthly averages to an ASCII file.
openw,OutLUN, OutFileName, /get_lun
printf,OutLUN, 'Mnth','  Fn_obs','  Fn_mod','  Fe_obs','  Fe_mod',$
               '  Fh_obs','  Fh_mod','     Fc_obs','     Fc_mod',$
               ' Sws_obs','Sws0_mod','  Rf_obs',format='(A4,6A8,2A11,3A8)'
printf,OutLUN, '   -','   W/m^2','   W/m^2','   W/m^2','   W/m^2',$
               '   W/m^2','   W/m^2',' umol/m^2/s',' umol/m^2/s',$
               ' m^3/m^3',' m^3/m^3','      mm',format='(A4,6A8,2A11,3A8)'
for i=0,11 do begin
 m=i+1
 printf,OutLUN, m, Fn_obs_month[i,0], Fn_mod_month[i,0], Fe_obs_month[i,0], Fe_mod_month[i,0], $
                Fh_obs_month[i,0], Fh_mod_month[i,0], Fc_obs_month[i,0], Fc_mod_month[i,0], $
                Sws_obs_month[i,0],Sws_mod_month[i,0],Rf_obs_month[i,0], $
                format='(I4,6F8.1,2F11.3,2F8.3,F8.1)'
endfor
free_lun, OutLUN

; *** Get the filename for the Postscript file.
SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EYear=Year[NRec-1] & EMonth=Month[NRec-1] & EDay=Day[NRec-1]
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
PSFileName=PltPath+'MP_Flux_'+SDate+'To'+EDate+'.eps'
print,'Graphics will be output to '+PSFileName

; *** Set up the Postscript device.
set_plot,'ps'
device, filename=PSFileName, /encapsulated, $
 xsize=29.7, ysize=21.0, bits=8, /color
thk=4              ; thickness scale factor for lines and fonts in Postscript output

; *** Set up the colours.  We will use the built-in "Rainbow+white"
; *** colour table.  The primary colours are returned in the structure ct.
definecolours_ct39, ct

; *** Get the Y axis maxima and minima
; **** Net radiation
FnMin=min([Fn_obs_month[*,0],Fn_mod_month[*,0]]) & FnMin=10*(fix(FnMin/10.)-1)
FnMax=max([Fn_obs_month[*,0],Fn_mod_month[*,0]]) & FnMax=10*(fix(FnMax/10.)+1)
; **** Sensible heat flux
FhMin=min([Fh_obs_month[*,0],Fh_mod_month[*,0]]) & FhMin=10*(fix(FhMin/10.)-1)
FhMax=max([Fh_obs_month[*,0],Fh_mod_month[*,0]]) & FhMax=10*(fix(FhMax/10.)+1)
; **** Latent heat flux
FeMin=min([Fe_obs_month[*,0],Fe_mod_month[*,0]]) & FeMin=10*(fix(FeMin/10.)-1)
FeMax=max([Fe_obs_month[*,0],Fe_mod_month[*,0]]) & FeMax=10*(fix(FeMax/10.)+1)
; **** CO2 flux
FcMin=min([Fc_obs_month[*,0],Fc_mod_month[*,0]]) & FcMin=1*(fix(FcMin/1.)-1)
FcMax=max([Fc_obs_month[*,0],Fc_mod_month[*,0]]) & FcMax=1*(fix(FcMax/1.)+1)

; *** Start plotting.
Mnth=indgen(12)+1
XMax=max(Mnth)
XMin=min(Mnth)
; **** Latent heat flux.
Row=1
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Mnth, Fe_obs_month[*,0], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,13], xthick=thk, xticks=4, xtickv=[0,3,6,9,12], xtitle='Month', $
 ystyle=1, yrange=[FeMin,FeMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Mnth, Fe_mod_month[*,0], thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Latent', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'CABLE', /normal, color=ct.blue, charthick=thk
; *** Net radiation.
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Mnth, Fn_obs_month[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,13], xthick=thk, xticks=4, xtickv=[0,3,6,9,12], xtitle='Month', $
 ystyle=1, yrange=[FnMin,FnMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Mnth, Fn_mod_month[*,0], thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Net radiation', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'CABLE', /normal, color=ct.blue, charthick=thk
; *** CO2 flux.
Row=2
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Mnth, Fc_obs_month[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,13], xthick=thk, xticks=4, xtickv=[0,3,6,9,12], xtickformat='(a1)', $
 ystyle=1, yrange=[FcMin,FcMax], ytitle='(umol/m!S!U2!R/s)', ythick=thk
oplot, Mnth, Fc_mod_month, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'NEE', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'CABLE', /normal, color=ct.blue, charthick=thk
; *** Sensible heat flux.
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Mnth, Fh_obs_month[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,13], xthick=thk, xticks=4, xtickv=[0,3,6,9,12], xtickformat='(a1)', $
 ystyle=1, yrange=[FhMin,FhMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Mnth, Fh_mod_month, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Sensible', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'CABLE', /normal, color=ct.blue, charthick=thk
; *** Title for the plot.
TitleString='CABLE: Monthly average fluxes for '+Site+' ; '+StartDate+' to '+Enddate
xyouts,0.5, 0.975, alignment=0.5, TitleString, /normal, charthick=thk

; *** Close the Postscript file and view it in GSview.
device, /close
if (!version.release ge 6) then $
 spawn,'gsview32 '+PSFileName, /nowait, /noshell $
else $
 spawn,'gsview32 '+PSFileName, /noshell

finish:
set_plot,'win'

end