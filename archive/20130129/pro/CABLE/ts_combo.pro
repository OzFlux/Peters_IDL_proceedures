pro ts_combo
; PROJECT: CABLE
;
; PURPOSE
;  To plot time series of the forcing meteorology and results for a CABLE run.
; USE
;  Type 'ts_combo' at the IDL prompt.  The procedure will put up a
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
ObsFilePath=getenv('ObsFilePath')
if strlen(ObsFilePath) eq 0 then $
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',FILTER='*.nc',GET_PATH=ObsFilePath) $
else $
 ObsFileName=Dialog_PickFile(TITLE='Select observations file',PATH=ObsFilePath,FILTER='*.nc',GET_PATH=ObsFilePath)
setenv, 'ObsFilePath='+ObsFilePath
; Get the base name of the observations file.
PathLen=strlen(ObsFilePath)
;DotPos=strpos(ObsFileName,'.',/REVERSE_SEARCH)
DotPos=rstrpos(ObsFileName,'.')
BaseName = strmid(ObsFileName, PathLen, DotPos-PathLen)
; Now get the model results file name etc.
ModFilePath=getenv('ModFilePath')
if strlen(ModFilePath) eq 0 then $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',FILTER='*.nc',GET_PATH=ModFilePath) $
else $
 ModFileName=Dialog_PickFile(TITLE='Select model results file',PATH=ModFilePath,FILTER='*.nc',GET_PATH=ModFilePath)
setenv, 'ModFilePath='+ModFilePath
; Get the path to the plot subdirectory.
s1=strpos(strlowcase(ModFilePath),'data')
PltPath=strmid(ModFilePath,0,s1)+'plots\'

; Open the observations file.
ncid_obs=ncdf_open(ObsFileName)
ncid_mod=ncdf_open(ModFileName)

; Get the time from the file and convert from seconds elapsed since
; the start date and time to year, month, day, hour, minute and
; second.
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

; Tell the user when the data starts, when it finishes and ask
; them for the date/time range to output.
StartDate=string(Day[0],format='(I2.2)')+'/'+string(Month[0],format='(I2.2)')+'/'+string(Year[0],format='(I4)')
StartTime=string(Hour[0],format='(I2.2)')+':'+string(Minute[0],format='(I2.2)')+':'+string(Second[0],format='(I2.2)')
EndDate=string(Day[NRec-1],format='(I2.2)')+'/'+string(Month[NRec-1],format='(I2.2)')+'/'+string(Year[NRec-1],format='(I4)')
EndTime=string(Hour[NRec-1],format='(I2.2)')+':'+string(Minute[NRec-1],format='(I2.2)')+':'+string(Second[NRec-1],format='(I2.2)')
print,'File starts at ',StartDate,' ',StartTime,' and ends at ',EndDate,' ',EndTime

; Get the variables from the observations file.
ObsList='SWdown,LWdown,Tair,Rainf,Qair,Fe,Qle,Fh,Qh,Fc,NEE,Fn,Rnet'
ObsList=strcompress(ObsList,/remove_all)
ObsNames=strsplit(ObsList,',',/extract,count=NObs)
for i=0,NObs-1 do begin
 VarID=ncdf_varid(ncid_obs,ObsNames[i])
 if (VarID ne -1) then begin
  case ObsNames[i] of
   'SWdown': ncdf_varget, ncid_obs, VarID, Fsd_obs         ; Shortwave downwelling radiation, W/m2
   'LWdown': ncdf_varget, ncid_obs, VarID, Fld_obs         ; Longwave downwelling radiation, W/m2
   'Tair'  : begin
     ncdf_varget, ncid_obs, VarID, Ta_obs
     Ta_obs=Ta_obs-273.2
     end
   'Rainf' : begin
     ncdf_varget, ncid_obs, VarID, Pt_obs          ; Total precipitation, kg/m2/s
     Pt_obs=Pt_obs*3600.
     end
   'Qair'  : ncdf_varget, ncid_obs, VarID, q_obs
   'Fe'    : ncdf_varget, ncid_obs, VarID, Fe_obs
   'Qle'   : ncdf_varget, ncid_obs, VarID, Fe_obs
   'Fh'    : ncdf_varget, ncid_obs, VarID, Fh_obs
   'Qh'    : ncdf_varget, ncid_obs, VarID, Fh_obs
   'Fc'    : ncdf_varget, ncid_obs, VarID, Fc_obs
   'NEE'   : ncdf_varget, ncid_obs, VarID, Fc_obs
   'Fn'    : ncdf_varget, ncid_obs, VarID, Fn_obs
   'Rnet'  : ncdf_varget, ncid_obs, VarID, Fn_obs
   else    : print,ObsNames[i]+' not matched in observations file'
  endcase
 endif else begin
  print, ObsNames[i]+' does not exist in observations file'
 endelse
endfor
; Get the variables from the model results file.
ModList='Qle,Qh,Qg,Qs,Qsb,Evap,ECanop,TVeg,ESoil,HVeg,HSoil,NEE,SoilMoist,SoilTemp,SnowDepth,SWnet,LWnet,VegT,CanopInt,AutoResp,HeteroResp,GPP'
ModList=strcompress(ModList,/remove_all)
ModNames=strsplit(ModList,',',/extract,count=NMod)
for i=0,NMod-1 do begin
 VarID=ncdf_varid(ncid_mod,ModNames[i])
 if (VarID ne -1) then begin
  case ModNames[i] of
   'Qle'        : ncdf_varget, ncid_mod, VarID, Fe_mod     ; Latent heat flux, W/m2
   'Qh'         : ncdf_varget, ncid_mod, VarID, Fh_mod     ; Sensible heat flux, W/m2
   'Qg'         : ncdf_varget, ncid_mod, VarID, Fg_mod     ; Ground heat flux, W/m2
   'Qs'         : begin
     ncdf_varget, ncid_mod, VarID, Rs_mod                  ; Surface runoff, kg/m2/s
     Rs_mod=Rs_mod*3600.
     end
   'Qsb'        : begin
     ncdf_varget, ncid_mod, VarID, Rss_mod                 ; Sub-surface runoff, kg/m2/s
     Rss_mod=Rss_mod*3600.
     end
   'Evap'       : begin
     ncdf_varget, ncid_mod, VarID, Et_mod                  ; Total evapotranspiration, kg/m2/s
     Fet_mod=Et_mod*2.45E6                                 ; Total evapotranspiration, W/m2
     end
   'ECanop'     : begin
     ncdf_varget, ncid_mod, VarID, Ecw_mod                 ; Wet canopy evaporation, kg/m2/s
     Fecw_mod=Ecw_mod*2.45E6                               ; Wet canopy evaporation, W/m2
     end
   'TVeg'       : begin
     ncdf_varget, ncid_mod, VarID, Ev_mod                  ; Vegetation transpiration, kg/m2/s
     Fev_mod=Ev_mod*2.45E6                                 ; Vegetation transpiration, W/m2
     end
   'ESoil'      : begin
     ncdf_varget, ncid_mod, VarID, Es_mod                  ; Soil evaporation, kg/m2/s
     Fes_mod=Es_mod*2.45E6                                 ; Soil evaporation, W/m2
     end
   'HVeg'       : ncdf_varget, ncid_mod, VarID, Fhv_mod    ; Sensible heat from vegetation, W/m2
   'HSoil'      : ncdf_varget, ncid_mod, VarID, Fhs_mod    ; Sensible heat from soil, W/m2
   'NEE'        : ncdf_varget, ncid_mod, VarID, Fc_mod     ; Net ecosystem exchange, umol/m2/s
   'SoilMoist'  : begin
     ncdf_varget, ncid_mod, VarID, Ms_mod                  ; Soil moisture for all 6 layers, kg/m2
     ThisID=ncdf_varid(ncid_mod,'zse')
     ncdf_varget, ncid_mod, ThisID, zse                    ; Depth of each soil layer
     Ms0_mod=Ms_mod[0,0,0,*]/zse[0,0,0]/1000.              ; Soil moisture for 1st layer, m3/m3
     Ms1_mod=Ms_mod[0,0,1,*]/zse[0,0,1]/1000.              ; Soil moisture for 2nd layer, m3/m3
     Ms2_mod=Ms_mod[0,0,2,*]/zse[0,0,2]/1000.              ; Soil moisture for 3rd layer, m3/m3
     Ms3_mod=Ms_mod[0,0,3,*]/zse[0,0,3]/1000.              ; Soil moisture for 4th layer, m3/m3
     Ms4_mod=Ms_mod[0,0,4,*]/zse[0,0,4]/1000.              ; Soil moisture for 5th layer, m3/m3
     Ms5_mod=Ms_mod[0,0,5,*]/zse[0,0,5]/1000.              ; Soil moisture for 6th layer, m3/m3
    end
   'SoilTemp'   : begin
     ncdf_varget, ncid_mod, VarID, Ts_mod                  ; Soil temperature for all 6 layers, K
     Ts0_mod=Ts_mod[0,0,0,*]-273.2                         ; Soil temperature for 1st layer, C
     Ts1_mod=Ts_mod[0,0,1,*]-273.2                         ; Soil temperature for 2nd layer, C
     Ts2_mod=Ts_mod[0,0,2,*]-273.2                         ; Soil temperature for 3rd layer, C
     Ts3_mod=Ts_mod[0,0,3,*]-273.2                         ; Soil temperature for 4th layer, C
     Ts4_mod=Ts_mod[0,0,4,*]-273.2                         ; Soil temperature for 5th layer, C
     Ts5_mod=Ts_mod[0,0,5,*]-273.2                         ; Soil temperature for 6th layer, C
    end
   'SnowDepth'  : ncdf_varget, ncid_mod, VarID, Zsd_mod    ; Snow depth, m
   'SWnet'      : ncdf_varget, ncid_mod, VarID, Fsn_mod    ; Net shortwave, W/m2
   'LWnet'      : ncdf_varget, ncid_mod, VarID, Fln_mod    ; Net longwave, W/m2
   'VegT'       : begin
     ncdf_varget, ncid_mod, VarID, Tv_mod                  ; Vegetation temperature, K
     Tv_mod=Tv_mod-273.2
     end
   'CanopInt'   : ncdf_varget, ncid_mod, VarID, Scw_mod    ; Canopy water storage, kg/m2
   'AutoResp'   : ncdf_varget, ncid_mod, VarID, Fca_mod    ; Autotrophic respiration, umol/m2/s
   'HeteroResp' : ncdf_varget, ncid_mod, VarID, Fch_mod    ; Heteortrophic respiration, umol/m2/s
   'GPP'        : ncdf_varget, ncid_mod, VarID, Fcg_mod    ; Gross primary productivity, umol/m2/s
   else         : print,ModNames[i]+' not matched in model results file'
  endcase
 endif
endfor
Fn_mod=Fsn_mod+Fln_mod

; Close the netCDF files.
ncdf_close, ncid_obs
ncdf_close, ncid_mod

; Set up the height of the Y axis.
NPlt=10
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
PSFileName=PltPath+'Combo_'+SDate+'To'+EDate+'.eps'

; Set up the Postscript device.
set_plot,'ps'
device, filename=PSFileName, /encapsulated, $
 xsize=21.7, ysize=29.7, bits=8, /color
athk=4              ; thickness scale factor for axis lines
cthk=4              ; thickness scale factor for fonts
lthk=3              ; thickness scale factor for plot lines

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
PltNo=0
; Plot 1 : Soil temperature
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Ts0_mod[Index]),min(Ts1_mod[Index]),min(Ts2_mod[Index]),min(Ts3_mod[Index]),$
          min(Ts4_mod[Index]),min(Ts5_mod[Index])])
YMax=max([max(Ts0_mod[Index]),max(Ts1_mod[Index]),max(Ts2_mod[Index]),max(Ts3_mod[Index]),$
          max(Ts4_mod[Index]),max(Ts5_mod[Index])])
plot, X, Ts0_mod[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='label_date', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Ts1_mod[Index], thick=lthk, color=ct.purple
oplot, X, Ts2_mod[Index], thick=lthk, color=ct.blue
oplot, X, Ts3_mod[Index], thick=lthk, color=ct.green
oplot, X, Ts4_mod[Index], thick=lthk, color=ct.yellow
oplot, X, Ts5_mod[Index], thick=lthk, color=ct.orange
xyouts,XPosBL+0.02,YPosTR-0.015,'Soil Temperature (C)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'1', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'2', /normal, color=ct.purple, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'3', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.40,YPosTR-0.015,'4', /normal, color=ct.green, charthick=cthk
xyouts,XPosBL+0.45,YPosTR-0.015,'5', /normal, color=ct.yellow, charthick=cthk
xyouts,XPosBL+0.50,YPosTR-0.015,'6', /normal, color=ct.orange, charthick=cthk
; Plot 2: Temperatures
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Ta_obs[Index]),min(Ts0_mod[Index]),min(Ts1_mod[Index]),min(Tv_mod[Index])])
YMax=max([max(Ta_obs[Index]),max(Ts0_mod[Index]),max(Ts1_mod[Index]),max(Tv_mod[Index])])
plot, X, Ta_obs[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Ts0_mod[Index], thick=lthk, color=ct.purple
oplot, X, Ts1_mod[Index], thick=lthk, color=ct.blue
oplot, X, Tv_mod[Index], thick=lthk, color=ct.green
xyouts,XPosBL+0.02,YPosTR-0.015,'Temperatures (C)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Ta', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Ts1', /normal, color=ct.purple, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Ts2', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.40,YPosTR-0.015,'Tv', /normal, color=ct.green, charthick=cthk
; Plot 3: Soil fluxes
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Fhs_mod[Index]),min(Fes_mod[Index]),min(Fg_mod[Index])])
YMax=max([max(Fhs_mod[Index]),max(Fes_mod[Index]),max(Fg_mod[Index])])
plot, X, Fhs_mod[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, /nodata, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Fhs_mod[Index], thick=lthk, color=ct.red
oplot, X, Fes_mod[Index], thick=lthk, color=ct.blue
oplot, X, Fg_mod[Index], thick=lthk, color=ct.green
xyouts,XPosBL+0.02,YPosTR-0.015,'Soil fluxes (W/m!S!U2!R)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Fhs', /normal, color=ct.red, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Fes', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Fg', /normal, color=ct.green, charthick=cthk
; Plot 4 : Canopy fluxes
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Fet_mod[Index]),min(Fecw_mod[Index]),min(Fev_mod[Index]),min(Fhv_mod[Index])])
YMax=max([max(Fet_mod[Index]),max(Fecw_mod[Index]),max(Fev_mod[Index]),max(Fhv_mod[Index])])
plot, X, Fet_mod[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Fecw_mod[Index], thick=lthk, color=ct.purple
oplot, X, Fev_mod[Index], thick=lthk, color=ct.blue
oplot, X, Fhv_mod[Index], thick=lthk, color=ct.red
xyouts,XPosBL+0.02,YPosTR-0.015,'Canopy fluxes (W/m!S!U2!R)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Fet', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Fecw', /normal, color=ct.purple, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Fev', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.40,YPosTR-0.015,'Fhv', /normal, color=ct.red, charthick=cthk
; Plot 5 : Soil moisture
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Ms0_mod[Index]),min(Ms1_mod[Index]),min(Ms2_mod[Index]),min(Ms3_mod[Index]),$
          min(Ms4_mod[Index]),min(Ms5_mod[Index])])
YMax=max([max(Ms0_mod[Index]),max(Ms1_mod[Index]),max(Ms2_mod[Index]),max(Ms3_mod[Index]),$
          max(Ms4_mod[Index]),max(Ms5_mod[Index])])
plot, X, Ms0_mod[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Ms1_mod[Index], thick=lthk, color=ct.purple
oplot, X, Ms2_mod[Index], thick=lthk, color=ct.blue
oplot, X, Ms3_mod[Index], thick=lthk, color=ct.green
oplot, X, Ms4_mod[Index], thick=lthk, color=ct.yellow
oplot, X, Ms5_mod[Index], thick=lthk, color=ct.orange
xyouts,XPosBL+0.02,YPosTR-0.015,'Soil Moisture (m!S!U3!R/m!S!U3!R)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'1', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'2', /normal, color=ct.purple, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'3', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.40,YPosTR-0.015,'4', /normal, color=ct.green, charthick=cthk
xyouts,XPosBL+0.45,YPosTR-0.015,'5', /normal, color=ct.yellow, charthick=cthk
xyouts,XPosBL+0.50,YPosTR-0.015,'6', /normal, color=ct.orange, charthick=cthk
; Plot 6 : Precipitation and runoff.
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Pt_obs[Index]),min(Scw_mod[Index]),min(Rs_mod[Index]),min(Rss_mod[Index])])
YMax=max([max(Pt_obs[Index]),max(Scw_mod[Index]),max(Rs_mod[Index]),max(Rss_mod[Index])])
plot, X, Pt_obs[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Scw_mod[Index], thick=lthk, color=ct.red
oplot, X, Rs_mod[Index], thick=lthk, color=ct.blue
oplot, X, Rss_mod[Index], thick=lthk, color=ct.green
xyouts,XPosBL+0.02,YPosTR-0.015,'Precip/Runoff (mm/hr)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Pt', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Scw', /normal, color=ct.red, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Rs', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.40,YPosTR-0.015,'Rss', /normal, color=ct.green, charthick=cthk
; Plot 7 : Radiation.
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Fsd_obs[Index]),min(Fn_obs[Index]),min(Fn_mod[Index])])
YMax=max([max(Fsd_obs[Index]),max(Fn_obs[Index]),max(Fn_mod[Index])])
plot, X, Fsd_obs[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Fn_obs[Index], thick=lthk, color=ct.blue
oplot, X, Fn_mod[Index], thick=lthk, color=ct.red
xyouts,XPosBL+0.02,YPosTR-0.015,'Radiation (W/m!S!U2!R)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Fsd', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Fn_o', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Fn_m', /normal, color=ct.red, charthick=cthk
; Plot 8 : Carbon fluxes
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Fc_obs[Index]),min(Fc_mod[Index]),min(Fca_mod[Index]),min(Fch_mod[Index])])
YMax=max([max(Fc_obs[Index]),max(Fc_mod[Index]),max(Fca_mod[Index]),max(Fch_mod[Index])])
plot, X, Fc_obs[Index], thick=lthk, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Fc_mod[Index], thick=lthk, color=ct.green
oplot, X, Fca_mod[Index], thick=lthk, color=ct.red
oplot, X, Fch_mod[Index], thick=lthk, color=ct.blue
xyouts,XPosBL+0.02,YPosBL+0.010,'Carbon fluxes (umol/m!S!U2!R/s)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosBL+0.010,'Fc_o', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosBL+0.010,'Fc_m', /normal, color=ct.green, charthick=cthk
xyouts,XPosBL+0.35,YPosBL+0.010,'Fca_m', /normal, color=ct.red, charthick=cthk
xyouts,XPosBL+0.40,YPosBL+0.010,'Fch_m', /normal, color=ct.blue, charthick=cthk
; Plot 9 : Model fluxes
PltNo=PltNo+1
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Fe_mod[Index]),min(Fh_mod[Index]),min(Fg_mod[Index])])
YMax=max([max(Fe_mod[Index]),max(Fh_mod[Index]),max(Fg_mod[Index])])
plot, X, Fe_mod[Index], thick=lthk, /nodata, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Fe_mod[Index], thick=lthk, color=ct.blue
oplot, X, Fh_mod[Index], thick=lthk, color=ct.red
oplot, X, Fg_mod[Index], thick=lthk, color=ct.green
xyouts,XPosBL+0.02,YPosTR-0.015,'Model fluxes (W/m!S!U2!R)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.25,YPosTR-0.015,'Fe_m', /normal, color=ct.blue, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Fh_m', /normal, color=ct.red, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Fg_m', /normal, color=ct.green, charthick=cthk
; Plot 10 : Albedo and snow depth
PltNo=PltNo+1
if (nele(Alb_mod) eq 0) then Alb_mod=0.3+0.0*Zsd_mod
YPosBL=MarginB+(PltNo-1)*YHeight
YPosTR=YPosBL+YHeight-0.01
YMin=min([min(Alb_mod[Index]),min(Zsd_mod[Index])])
YMax=max([max(Alb_mod[Index]),max(Zsd_mod[Index])])
plot, X, Alb_mod[Index], thick=lthk, /nodata, $
 position=[XPosBL,YPosBL,XPosTR,YPosTR], charthick=cthk, /noerase, $
 xstyle=1, xrange=[XMin,XMax], xtickformat='(a1)', xthick=athk, $
 ystyle=1, yrange=[YMin,YMax], ythick=athk
oplot, X, Zsd_mod[Index], thick=lthk, color=ct.blue
xyouts,XPosBL+0.02,YPosTR-0.015,'Albedo (-) & snow depth (m)', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.30,YPosTR-0.015,'Alb_m', /normal, color=ct.black, charthick=cthk
xyouts,XPosBL+0.35,YPosTR-0.015,'Zsd_m', /normal, color=ct.blue, charthick=cthk

TitleString='CABLE: Fluxes for '+BaseName+' ; '+StartDate+' to '+Enddate
xyouts,0.5, 0.95, alignment=0.5, TitleString, /normal, charthick=cthk

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