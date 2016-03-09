pro dp_flux
; PROJECT: ACASA
;
; PURPOSE
;  To plot diurnal average values of net radiation, latent heat flux, sensible
;  heat flux and CO2 flux for each season over a 12 month period.
; USE
;  Type 'dp_flux' at the IDL command prompt.  The procedure will put up a
;  dialog box to allow the observations and model results file to be chosen.
;  A Postscript file of the plot of diurnal averages is produced and a GSview
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
NRows=4
NCols=4
MarginB=0.075      ; bottom margin
MarginL=0.075      ; left margin
MarginT=0.075      ; top margin
MarginR=0.025      ; right margin
YMargin=0.01
XMargin=0.01
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
nRecs_obs=nLines-1               ; One header line in the observations file
; *** Declare the arrays to hold the observed data.
xday_obs=make_array(nRecs_obs,/double)
var1=double(0.0)
Fn_obs=make_array(nRecs_obs,/float)
Fe_obs=make_array(nRecs_obs,/float)
Fh_obs=make_array(nRecs_obs,/float)
Fc_obs=make_array(nRecs_obs,/float)
Year_obs=make_array(nRecs_obs,/float)
; *** Read the data from the observations file.
for i=0,nRecs_obs-1 do begin
 readf,ObsLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15
 xday_obs[i]=var1
 Fn_obs[i]=var10
 Fe_obs[i]=var11
 Fh_obs[i]=var12
 Fc_obs[i]=var13
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
Year_mod=make_array(nRecs_mod,/float)
; *** Read the data from the model results file.
for i=0,nRecs_mod-1 do begin
 readf,ModLUN,var1,var2,var3,var4,var5,var6,var7,var8,var9,var10,var11,var12,var13,var14,var15,var16,var17,var18,var19,var20,var21,var22
 xday_mod[i]=var1
 Fn_mod[i]=var2
 Fh_mod[i]=var9
 Fe_mod[i]=var10
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
Fn_obs=Fn_obs[Index_obs]
Fe_obs=Fe_obs[Index_obs]
Fh_obs=Fh_obs[Index_obs]
Fc_obs=Fc_obs[Index_obs]
xday_mod=xday_mod[Index_mod]
Year_mod=Year_mod[Index_mod]
Fn_mod=Fn_mod[Index_mod]
Fe_mod=Fe_mod[Index_mod]
Fh_mod=Fh_mod[Index_mod]
Fc_mod=Fc_mod[Index_mod]
; *** Now get the data for the same times.
diff=xday_obs-xday_mod
Index=where(diff lt 0.000001,count)
if count lt fix(0.95*nRecs_obs) then begin
 print,'Times in obs and model results are not equal for >5% of records'
 stop
endif
xday=xday_obs[Index]
Year=Year_obs[Index]
Fn_obs=Fn_obs[Index]
Fe_obs=Fe_obs[Index]
Fh_obs=Fh_obs[Index]
Fc_obs=Fc_obs[Index]
Fn_mod=Fn_mod[Index]
Fe_mod=Fe_mod[Index]
Fh_mod=Fh_mod[Index]
Fc_mod=Fc_mod[Index]
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

; *** Get the average for each hour of the day over each season.
; **** Summer
Fn_obs_djf=make_array(24,2,/float)
Fn_mod_djf=make_array(24,2,/float)
Fh_obs_djf=make_array(24,2,/float)
Fh_mod_djf=make_array(24,2,/float)
Fe_obs_djf=make_array(24,2,/float)
Fe_mod_djf=make_array(24,2,/float)
Fc_obs_djf=make_array(24,2,/float)
Fc_mod_djf=make_array(24,2,/float)
for i=0, 23 do begin
 Index=where((Month eq 12 or Month eq 1 or Month eq 2) and Hour eq i,count)
 Fn_obs_djf[i,0]=mean(Fn_obs[Index])
 Fn_obs_djf[i,1]=stddev(Fn_obs[Index])
 Fn_mod_djf[i,0]=mean(Fn_mod[Index])
 Fn_mod_djf[i,1]=stddev(Fn_mod[Index])
 Fh_obs_djf[i,0]=mean(Fh_obs[Index])
 Fh_obs_djf[i,1]=stddev(Fh_obs[Index])
 Fh_mod_djf[i,0]=mean(Fh_mod[Index])
 Fh_mod_djf[i,1]=stddev(Fh_mod[Index])
 Fe_obs_djf[i,0]=mean(Fe_obs[Index])
 Fe_obs_djf[i,1]=stddev(Fe_obs[Index])
 Fe_mod_djf[i,0]=mean(Fe_mod[Index])
 Fe_mod_djf[i,1]=stddev(Fe_mod[Index])
 Fc_obs_djf[i,0]=mean(Fc_obs[Index])
 Fc_obs_djf[i,1]=stddev(Fc_obs[Index])
 Fc_mod_djf[i,0]=mean(Fc_mod[Index])
 Fc_mod_djf[i,1]=stddev(Fc_mod[Index])
end
; **** Autumn
Fn_obs_mam=make_array(24,2,/float)
Fn_mod_mam=make_array(24,2,/float)
Fh_obs_mam=make_array(24,2,/float)
Fh_mod_mam=make_array(24,2,/float)
Fe_obs_mam=make_array(24,2,/float)
Fe_mod_mam=make_array(24,2,/float)
Fc_obs_mam=make_array(24,2,/float)
Fc_mod_mam=make_array(24,2,/float)
for i=0, 23 do begin
 Index=where((Month eq 3 or Month eq 4 or Month eq 5) and Hour eq i)
 Fn_obs_mam[i,0]=mean(Fn_obs[Index])
 Fn_obs_mam[i,1]=stddev(Fn_obs[Index])
 Fn_mod_mam[i,0]=mean(Fn_mod[Index])
 Fn_mod_mam[i,1]=stddev(Fn_mod[Index])
 Fh_obs_mam[i,0]=mean(Fh_obs[Index])
 Fh_obs_mam[i,1]=stddev(Fh_obs[Index])
 Fh_mod_mam[i,0]=mean(Fh_mod[Index])
 Fh_mod_mam[i,1]=stddev(Fh_mod[Index])
 Fe_obs_mam[i,0]=mean(Fe_obs[Index])
 Fe_obs_mam[i,1]=stddev(Fe_obs[Index])
 Fe_mod_mam[i,0]=mean(Fe_mod[Index])
 Fe_mod_mam[i,1]=stddev(Fe_mod[Index])
 Fc_obs_mam[i,0]=mean(Fc_obs[Index])
 Fc_obs_mam[i,1]=stddev(Fc_obs[Index])
 Fc_mod_mam[i,0]=mean(Fc_mod[Index])
 Fc_mod_mam[i,1]=stddev(Fc_mod[Index])
end
; **** Winter
Fn_obs_jja=make_array(24,2,/float)
Fn_mod_jja=make_array(24,2,/float)
Fh_obs_jja=make_array(24,2,/float)
Fh_mod_jja=make_array(24,2,/float)
Fe_obs_jja=make_array(24,2,/float)
Fe_mod_jja=make_array(24,2,/float)
Fc_obs_jja=make_array(24,2,/float)
Fc_mod_jja=make_array(24,2,/float)
for i=0, 23 do begin
 Index=where((Month eq 6 or Month eq 7 or Month eq 8) and Hour eq i)
 Fn_obs_jja[i,0]=mean(Fn_obs[Index])
 Fn_obs_jja[i,1]=stddev(Fn_obs[Index])
 Fn_mod_jja[i,0]=mean(Fn_mod[Index])
 Fn_mod_jja[i,1]=stddev(Fn_mod[Index])
 Fh_obs_jja[i,0]=mean(Fh_obs[Index])
 Fh_obs_jja[i,1]=stddev(Fh_obs[Index])
 Fh_mod_jja[i,0]=mean(Fh_mod[Index])
 Fh_mod_jja[i,1]=stddev(Fh_mod[Index])
 Fe_obs_jja[i,0]=mean(Fe_obs[Index])
 Fe_obs_jja[i,1]=stddev(Fe_obs[Index])
 Fe_mod_jja[i,0]=mean(Fe_mod[Index])
 Fe_mod_jja[i,1]=stddev(Fe_mod[Index])
 Fc_obs_jja[i,0]=mean(Fc_obs[Index])
 Fc_obs_jja[i,1]=stddev(Fc_obs[Index])
 Fc_mod_jja[i,0]=mean(Fc_mod[Index])
 Fc_mod_jja[i,1]=stddev(Fc_mod[Index])
end
; **** Spring
Fn_obs_son=make_array(24,2,/float)
Fn_mod_son=make_array(24,2,/float)
Fh_obs_son=make_array(24,2,/float)
Fh_mod_son=make_array(24,2,/float)
Fe_obs_son=make_array(24,2,/float)
Fe_mod_son=make_array(24,2,/float)
Fc_obs_son=make_array(24,2,/float)
Fc_mod_son=make_array(24,2,/float)
for i=0, 23 do begin
 Index=where((Month eq 9 or Month eq 10 or Month eq 11) and Hour eq i)
 Fn_obs_son[i,0]=mean(Fn_obs[Index])
 Fn_obs_son[i,1]=stddev(Fn_obs[Index])
 Fn_mod_son[i,0]=mean(Fn_mod[Index])
 Fn_mod_son[i,1]=stddev(Fn_mod[Index])
 Fh_obs_son[i,0]=mean(Fh_obs[Index])
 Fh_obs_son[i,1]=stddev(Fh_obs[Index])
 Fh_mod_son[i,0]=mean(Fh_mod[Index])
 Fh_mod_son[i,1]=stddev(Fh_mod[Index])
 Fe_obs_son[i,0]=mean(Fe_obs[Index])
 Fe_obs_son[i,1]=stddev(Fe_obs[Index])
 Fe_mod_son[i,0]=mean(Fe_mod[Index])
 Fe_mod_son[i,1]=stddev(Fe_mod[Index])
 Fc_obs_son[i,0]=mean(Fc_obs[Index])
 Fc_obs_son[i,1]=stddev(Fc_obs[Index])
 Fc_mod_son[i,0]=mean(Fc_mod[Index])
 Fc_mod_son[i,1]=stddev(Fc_mod[Index])
end

; *** Get the filename for the Postscript file.
SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
SDate=string(SYear,format='(I4)')+string(SMonth,format='(I2.2)')+string(SDay,format='(I2.2)')
EYear=Year[nRecs-1] & EMonth=Month[nRecs-1] & EDay=Day[nRecs-1]
EDate=string(EYear,format='(I4)')+string(EMonth,format='(I2.2)')+string(EDay,format='(I2.2)')
OutFileName=ModFilePath+'DP_Flux_'+SDate+'To'+EDate+'.dat'

; *** Write the hourly averages to an ASCII file.
openw,OutLUN, OutFileName, /get_lun
printf,OutLUN,'Summer'
printf,OutLUN, 'Hr','Fn_obs','Fn_mod','Fe_obs','Fe_mod',$
               'Fh_obs','Fh_mod','Fc_obs','Fc_mod',format='(A4,6A8,2A11)'
printf,OutLUN, '-','W/m^2','W/m^2','W/m^2','W/m^2',$
               'W/m^2','W/m^2','umol/m^2/s','umol/m^2/s',format='(A4,6A8,2A11)'
h=0
for i=0,23 do begin
 h=i+1
 printf,OutLUN, h, Fn_obs_djf[i,0], Fn_mod_djf[i,0], Fe_obs_djf[i,0], Fe_mod_djf[i,0], $
                Fh_obs_djf[i,0], Fh_mod_djf[i,0], Fc_obs_djf[i,0], Fc_mod_djf[i,0], $
                format='(I4,6F8.1,2F11.3)'
endfor
printf,OutLUN,'Autumn'
printf,OutLUN, 'Hr','Fn_obs','Fn_mod','Fe_obs','Fe_mod',$
               'Fh_obs','Fh_mod','Fc_obs','Fc_mod',format='(A4,6A8,2A11)'
printf,OutLUN, '-','W/m^2','W/m^2','W/m^2','W/m^2',$
               'W/m^2','W/m^2','umol/m^2/s','umol/m^2/s',format='(A4,6A8,2A11)'
h=0
for i=0,23 do begin
 h=i+1
 printf,OutLUN, h, Fn_obs_mam[i,0], Fn_mod_mam[i,0], Fe_obs_mam[i,0], Fe_mod_mam[i,0], $
                Fh_obs_mam[i,0], Fh_mod_mam[i,0], Fc_obs_mam[i,0], Fc_mod_mam[i,0], $
                format='(I4,6F8.1,2F11.3)'
endfor
printf,OutLUN,'Winter'
printf,OutLUN, 'Hr','Fn_obs','Fn_mod','Fe_obs','Fe_mod',$
               'Fh_obs','Fh_mod','Fc_obs','Fc_mod',format='(A4,6A8,2A11)'
printf,OutLUN, '-','W/m^2','W/m^2','W/m^2','W/m^2',$
               'W/m^2','W/m^2','umol/m^2/s','umol/m^2/s',format='(A4,6A8,2A11)'
h=0
for i=0,23 do begin
 h=i+1
 printf,OutLUN, h, Fn_obs_jja[i,0], Fn_mod_jja[i,0], Fe_obs_jja[i,0], Fe_mod_jja[i,0], $
                Fh_obs_jja[i,0], Fh_mod_jja[i,0], Fc_obs_jja[i,0], Fc_mod_jja[i,0], $
                format='(I4,6F8.1,2F11.3)'
endfor
printf,OutLUN,'Spring'
printf,OutLUN, 'Hr','Fn_obs','Fn_mod','Fe_obs','Fe_mod',$
               'Fh_obs','Fh_mod','Fc_obs','Fc_mod',format='(A4,6A8,2A11)'
printf,OutLUN, '-','W/m^2','W/m^2','W/m^2','W/m^2',$
               'W/m^2','W/m^2','umol/m^2/s','umol/m^2/s',format='(A4,6A8,2A11)'
h=0
for i=0,23 do begin
 h=i+1
 printf,OutLUN, h, Fn_obs_son[i,0], Fn_mod_son[i,0], Fe_obs_son[i,0], Fe_mod_son[i,0], $
                Fh_obs_son[i,0], Fh_mod_son[i,0], Fc_obs_son[i,0], Fc_mod_son[i,0], $
                format='(I4,6F8.1,2F11.3)'
endfor
free_lun, OutLUN

PSFileName=PltPath+'DP_Flux_'+SDate+'To'+EDate+'.eps'
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
FnMin=min([Fn_obs_djf[*,0],Fn_obs_mam[*,0],Fn_obs_jja[*,0],Fn_obs_son[*,0]])
FnMin=min([FnMin,Fn_mod_djf[*,0],Fn_mod_mam[*,0],Fn_mod_jja[*,0],Fn_mod_son[*,0]])
FnMin=100*(fix(FnMin/100.)-1)
FnMax=max([Fn_obs_djf[*,0],Fn_obs_mam[*,0],Fn_obs_jja[*,0],Fn_obs_son[*,0]])
FnMax=max([FnMax,Fn_mod_djf[*,0],Fn_mod_mam[*,0],Fn_mod_jja[*,0],Fn_mod_son[*,0]])
FnMax=100*(fix(FnMax/100.)+1)
; **** Sensible heat flux
FhMin=min([Fh_obs_djf[*,0],Fh_obs_mam[*,0],Fh_obs_jja[*,0],Fh_obs_son[*,0]])
FhMin=min([FhMin,Fh_mod_djf[*,0],Fh_mod_mam[*,0],Fh_mod_jja[*,0],Fh_mod_son[*,0]])
FhMin=100*(fix(FhMin/100.)-1)
FhMax=max([Fh_obs_djf[*,0],Fh_obs_mam[*,0],Fh_obs_jja[*,0],Fh_obs_son[*,0]])
FhMax=max([FhMax,Fh_mod_djf[*,0],Fh_mod_mam[*,0],Fh_mod_jja[*,0],Fh_mod_son[*,0]])
FhMax=100*(fix(FhMax/100.)+1)
; **** Latent heat flux
FeMin=min([Fe_obs_djf[*,0],Fe_obs_mam[*,0],Fe_obs_jja[*,0],Fe_obs_son[*,0]])
FeMin=min([FeMin,Fe_mod_djf[*,0],Fe_mod_mam[*,0],Fe_mod_jja[*,0],Fe_mod_son[*,0]])
FeMin=100*(fix(FeMin/100.)-1)
FeMax=max([Fe_obs_djf[*,0],Fe_obs_mam[*,0],Fe_obs_jja[*,0],Fe_obs_son[*,0]])
FeMax=max([FeMax,Fe_mod_djf[*,0],Fe_mod_mam[*,0],Fe_mod_jja[*,0],Fe_mod_son[*,0]])
FeMax=100*(fix(FeMax/100.)+1)
; **** CO2 flux
FcMin=min([Fc_obs_djf[*,0],Fc_obs_mam[*,0],Fc_obs_jja[*,0],Fc_obs_son[*,0]])
FcMin=min([FcMin,Fc_mod_djf[*,0],Fc_mod_mam[*,0],Fc_mod_jja[*,0],Fc_mod_son[*,0]])
FcMin=5*(fix(FcMin/5.)-1)
FcMax=max([Fc_obs_djf[*,0],Fc_obs_mam[*,0],Fc_obs_jja[*,0],Fc_obs_son[*,0]])
FcMax=max([FcMax,Fc_mod_djf[*,0],Fc_mod_mam[*,0],Fc_mod_jja[*,0],Fc_mod_son[*,0]])
FcMax=5*(fix(FcMax/5.)+1)

; *** Start plotting.
Hrs=indgen(24)
XMax=max(Hrs)
XMin=min(Hrs)
; **** Net radiation
Row=1
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fn_obs_djf[*,0], thick=thk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtitle='Hour', $
 ystyle=1, yrange=[FnMin,FnMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Hrs, Fn_mod_djf, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Net radiation', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fn_obs_mam[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtitle='Hour', $
 ystyle=1, yrange=[FnMin,FnMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fn_mod_mam, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=3
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fn_obs_jja[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtitle='Hour', $
 ystyle=1, yrange=[FnMin,FnMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fn_mod_jja, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=4
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fn_obs_son[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtitle='Hour', $
 ystyle=1, yrange=[FnMin,FnMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fn_mod_son, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
; *** Sensible heat flux
Row=2
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fh_obs_djf[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FhMin,FhMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Hrs, Fh_mod_djf, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Sensible', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fh_obs_mam[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FhMin,FhMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fh_mod_mam, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=3
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fh_obs_jja[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FhMin,FhMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fh_mod_jja, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=4
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fh_obs_son[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FhMin,FhMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fh_mod_son, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
; *** Latent heat flux
Row=3
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fe_obs_djf[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FeMin,FeMax], ytitle='(W/m!S!U2!R)', ythick=thk
oplot, Hrs, Fe_mod_djf, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'Latent', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fe_obs_mam[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FeMin,FeMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fe_mod_mam, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=3
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fe_obs_jja[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FeMin,FeMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fe_mod_jja, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
Col=4
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fe_obs_son[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FeMin,FeMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fe_mod_son, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
; *** CO2 flux
Row=4
Col=1
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fc_obs_djf[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FcMin,FcMax], ytitle='(umol/m!S!U2!R/s)', ythick=thk
oplot, Hrs, Fc_mod_djf, thick=thk, color=ct.blue
xyouts,XPosBL+0.01,YPosTR-0.02,'NEE', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
xyouts,(XPosBL+XPosTR)/2,YPosTR+0.02,'Summer',/normal,alignment=0.5,charthick=thk
Col=2
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fc_obs_mam[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FcMin,FcMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fc_mod_mam, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
xyouts,(XPosBL+XPosTR)/2,YPosTR+0.02,'Autumn',/normal,alignment=0.5,charthick=thk
Col=3
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fc_obs_jja[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FcMin,FcMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fc_mod_jja, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
xyouts,(XPosBL+XPosTR)/2,YPosTR+0.02,'Winter',/normal,alignment=0.5,charthick=thk
Col=4
YPosBL=MarginB+(Row-1)*(YHeight+YMargin)
XPosBL=MarginL+(Col-1)*(XWidth+XMargin)
YPosTR=YPosBL+YHeight
XPosTR=XPosBL+XWidth
plot, Hrs, Fc_obs_son[*,0], thick=thk, /noerase, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=thk, $
 xstyle=1, xrange=[-1,25], xthick=thk, xticks=4, xtickv=[0,6,12,18,24], xtickformat='(a1)', $
 ystyle=1, yrange=[FcMin,FcMax], ythick=thk, ytickformat='(a1)'
oplot, Hrs, Fc_mod_son, thick=thk, color=ct.blue
xyouts,XPosTR-0.05,YPosTR-0.02,'Obs', /normal, color=ct.black, charthick=thk
xyouts,XPosTR-0.05,YPosTR-0.04,'ACASA', /normal, color=ct.blue, charthick=thk
xyouts,(XPosBL+XPosTR)/2,YPosTR+0.02,'Spring',/normal,alignment=0.5,charthick=thk
; *** Title for the plot.
TitleString='ACASA: Diurnal average fluxes for '+Site+' ; '+StartDate+' to '+Enddate
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