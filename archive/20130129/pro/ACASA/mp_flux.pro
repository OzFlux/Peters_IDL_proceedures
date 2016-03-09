pro mp_flux
; PROJECT: ACASA
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
; DATE: 04/11/2007
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
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',GET_PATH=ObsFilePath) $
else $
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',PATH=ObsFilePath,GET_PATH=ObsFilePath)
if (strlen(ObsFileName) eq 0) then goto, finish
setenv, 'ObsFilePath='+ObsFilePath
; *** Now get the model results file name etc.
ModFilePath=getenv('ModFilePath')
if strlen(ModFilePath) eq 0 then $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',GET_PATH=ModFilePath) $
else $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',PATH=ModFilePath,GET_PATH=ModFilePath)
if (strlen(ModFileName) eq 0) then goto, finish
setenv, 'ModFilePath='+ModFilePath
; *** Get the path to the plot subdirectory.
PltPath=ModFilePath+'plots\'

; *** Open the observations file and get the number of lines in the file.
openr,ObsLUN,ObsFileName,/get_lun
nLines=numlines(ObsLUN)
Header=''
readf,ObsLUN,Header
nRecs_o=nLines-1               ; One header line in the observations file
; *** Declare the arrays to hold the observed data.
xday_o=make_array(nRecs_o,/double)
var1=double(0.0)
Fn_o=make_array(nRecs_o,/float)
Fe_o=make_array(nRecs_o,/float)
Fh_o=make_array(nRecs_o,/float)
Fc_o=make_array(nRecs_o,/float)
Year_o=make_array(nRecs_o,/float)
; *** Read the data from the observations file.
for i=0,nRecs_o-1 do begin
 readf,ObsLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15
 xday_o[i]=var1
 Fn_o[i]=var10
 Fe_o[i]=var11
 Fh_o[i]=var12
 Fc_o[i]=var13
endfor
; *** Close the observations file.
free_lun, ObsLUN
; *** Generate a series for the year.
Year_o[0]=BaseYear
for i=1,nRecs_o-1 do begin
 if xday_o[i] gt xday_o[i-1] then Year_o[i]=Year_o[i-1] else Year_o[i]=Year_o[i-1]+1
endfor

; *** Open the model results file and get the number of lines in the file.
openr,ModLUN,ModFileName,/get_lun
nLines=numlines(ModLUN)
Header=''
nRecs_m=nLines
for i=0,0 do begin
 readf,ModLUN,Header
 nRecs_m=nRecs_m-1               ; One header line in the model results file
endfor
; *** Check to make sure we have the same number of records in the observations
; *** model results files.
;if nRecs_o ne nRecs_m then begin
; print,'nRecs_o (',nRecs_o,') and nRecs_m (',nRecs_m,') are not equal'
; stop
;endif
; *** Declare the arrays to hold the model results.
xday_m=make_array(nRecs_m,/double)
var1=double(0.0)
Fn_m=make_array(nRecs_m,/float)
Fe_m=make_array(nRecs_m,/float)
Fh_m=make_array(nRecs_m,/float)
Fc_m=make_array(nRecs_m,/float)
Year_m=make_array(nRecs_m,/float)
; *** Read the data from the model results file.
for i=0,nRecs_m-1 do begin
 readf,ModLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15,var16,var17,var18,var19,var20,var21,var22
 xday_m[i]=var1
 Fn_m[i]=var2
 Fh_m[i]=var9
 Fe_m[i]=var10
 Fc_m[i]=var16
endfor
; *** Close the observations file.
free_lun, ModLUN
; *** Generate a series for the year.
Year_m[0]=BaseYear
for i=1,nRecs_m-1 do begin
 if xday_m[i] gt xday_m[i-1] then Year_m[i]=Year_m[i-1] else Year_m[i]=Year_m[i-1]+1
endfor
; *** Check to see that we have data at the same times.
; *** Need to work with Julian day to avoid problems with 365/0 discontinuity
; *** when the year changes.
SJDay=julday(1,1,Year_o,0,0,0)
JDay_o=double(SJDay)+double(xday_o)        ; Use of double may be redundant
SJDay=julday(1,1,Year_m,0,0,0)
JDay_m=double(SJDay)+double(xday_m)        ; Use of double may be redundant
; ***  First we get the times when there is data for both observations and model results.
SDay=max([JDay_o[0],JDay_m[0]])
EDay=min([JDay_o[nRecs_o-1],JDay_m[nRecs_m-1]])
Idx_o=where(JDay_o ge SDay and JDay_o le EDay, cnt_o)
if cnt_o eq 0 then begin
 print,'No observations between start (',SDay,') and end (',EDay,') times'
 stop
endif
Idx_m=where(JDay_m ge SDay and JDay_m le EDay, cnt_m)
if cnt_m eq 0 then begin
 print,'No model results between start (',SDay,') and end (',EDay,') times'
 stop
endif
if cnt_o ne cnt_m then begin
 print,'Number of observations (',cnt_o,') and model results (',cnt_m,') not equal'
 stop
endif
; *** Get the data between the start and end times.
xday_o=xday_o[Idx_o]
Year_o=Year_o[Idx_o]
Fn_o=Fn_o[Idx_o]
Fe_o=Fe_o[Idx_o]
Fh_o=Fh_o[Idx_o]
Fc_o=Fc_o[Idx_o]
xday_m=xday_m[Idx_m]
Year_m=Year_m[Idx_m]
Fn_m=Fn_m[Idx_m]
Fe_m=Fe_m[Idx_m]
Fh_m=Fh_m[Idx_m]
Fc_m=Fc_m[Idx_m]
; *** Now get the data for the same times.
diff=xday_o-xday_m
Index=where(diff lt 0.000001,cnt)
if cnt lt fix(0.95*nRecs_o) then begin
 print,'Times in obs and model results are not equal for >5% of records'
 stop
endif
xday=xday_o[Index]
Year=Year_o[Index]
Fn_o=Fn_o[Index]
Fe_o=Fe_o[Index]
Fh_o=Fh_o[Index]
Fc_o=Fc_o[Index]
Fn_m=Fn_m[Index]
Fe_m=Fe_m[Index]
Fh_m=Fh_m[Index]
Fc_m=Fc_m[Index]
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

; *** Get the average for each month.
Fn_obs_month=make_array(12,2,/float)
Fn_mod_month=make_array(12,2,/float)
Fe_obs_month=make_array(12,2,/float)
Fe_mod_month=make_array(12,2,/float)
Fh_obs_month=make_array(12,2,/float)
Fh_mod_month=make_array(12,2,/float)
Fc_obs_month=make_array(12,2,/float)
Fc_mod_month=make_array(12,2,/float)
for i=0, 11 do begin
 Index=where(Month eq (i+1),count)
 Fn_obs_month[i,0]=mean(Fn_o[Index])
 Fn_obs_month[i,1]=stddev(Fn_o[Index])
 Fn_mod_month[i,0]=mean(Fn_m[Index])
 Fn_mod_month[i,1]=stddev(Fn_m[Index])
 Fe_obs_month[i,0]=mean(Fe_o[Index])
 Fe_obs_month[i,1]=stddev(Fe_o[Index])
 Fe_mod_month[i,0]=mean(Fe_m[Index])
 Fe_mod_month[i,1]=stddev(Fe_m[Index])
 Fh_obs_month[i,0]=mean(Fh_o[Index])
 Fh_obs_month[i,1]=stddev(Fh_o[Index])
 Fh_mod_month[i,0]=mean(Fh_m[Index])
 Fh_mod_month[i,1]=stddev(Fh_m[Index])
 Fc_obs_month[i,0]=mean(Fc_o[Index])
 Fc_obs_month[i,1]=stddev(Fc_o[Index])
 Fc_mod_month[i,0]=mean(Fc_m[Index])
 Fc_mod_month[i,1]=stddev(Fc_m[Index])
endfor

; *** Get the filename for the output file.
SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EYear=Year[nRecs-1] & EMonth=Month[nRecs-1] & EDay=Day[nRecs-1]
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
OutFileName=ModFilePath+'MP_Flux_'+SDate+'To'+EDate+'.dat'

; *** Write the monthly averages to an ASCII file.
openw,OutLUN, OutFileName, /get_lun
printf,OutLUN, 'Mnth','  Fn_obs','  Fn_mod','  Fe_obs','  Fe_mod',$
               '  Fh_obs','  Fh_mod','     Fc_obs','     Fc_mod',format='(A4,6A8,2A11)'
printf,OutLUN, '   -','   W/m^2','   W/m^2','   W/m^2','   W/m^2',$
               '   W/m^2','   W/m^2',' umol/m^2/s',' umol/m^2/s',format='(A4,6A8,2A11)'
for i=0,11 do begin
 m=i+1
 printf,OutLUN, m, Fn_obs_month[i,0], Fn_mod_month[i,0], Fe_obs_month[i,0], Fe_mod_month[i,0], $
                Fh_obs_month[i,0], Fh_mod_month[i,0], Fc_obs_month[i,0], Fc_mod_month[i,0], $
                format='(I4,6F8.1,2F11.3)'
endfor
free_lun, OutLUN

; *** Get the filename for the Postscript file.
SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EYear=Year[nRecs-1] & EMonth=Month[nRecs-1] & EDay=Day[nRecs-1]
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
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
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
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
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
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
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
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
; *** Title for the plot.
TitleString='ACASA: Monthly average fluxes for '+Site+' ; '+StartDate+' to '+Enddate
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