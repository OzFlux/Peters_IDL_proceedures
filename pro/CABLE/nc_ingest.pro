pro nc_ingest
; PROJECT: CABLE
;
; PURPOSE
; USE
; METHOD
;  RTSC at this time.
;
; ASSUMPTIONS
; SIDE EFFECTS
; CALLS
; AUTHOR: Peter Isaac (SGES, Monash University)
; DATE: 9/12/2010
; MODIFICATIONS
;  Re-written for GDL

 latitude=-12.49425
 longitude=131.15238
 isoil=4
 iveg=6
 writeLAI=1
 writefrac4=1
 TimeStep=30.

 InFilePath = '/home/data/ARCSpatial/Sites/HowardSprings/Data/Processed/Misc/'
 InFileName = '20040601To20050531'
 InFile = InFilePath+InFileName+'.csv'
 ncFile = InFilePath+InFileName+'.nc'

 print,'nc_ingest2: Opening CSV file for read'
 openr, InLun, InFile, /get_lun
 nTimeSteps=numlines(InLun)
 OneLine=''
 readf, InLun, OneLine
 Header=strsplit(OneLine,',',/extract,count=NFields)
 nTimeSteps=nTimeSteps-1

 print,'nc_ingest2: Reading CSV file'
 Data = MAKE_ARRAY(NFields, nTimeSteps, /FLOAT)
 FOR i = 0, nTimeSteps-1 DO BEGIN
  READF, InLun, OneLine
  Data[*,i] = strsplit(OneLine,',',/extract,count=NFields)
 ENDFOR
 free_lun, InLun
; *** Get the date and time information out of the file now so that we can
; *** write the start date and time into the attributes for the time variable.
 print,'nc_ingest2: Loading data into arrays'
 nVars=9                           ; There will be 9 basic variables in the netCDF file.
 VarList=','
 for i=0,NFields-1 do begin
  if strupcase(Header[i]) eq 'YEAR' then Year=Data[i,*]
  if strupcase(Header[i]) eq 'MONTH' then Month=Data[i,*]
  if strupcase(Header[i]) eq 'DAY' then Day=Data[i,*]
  if strupcase(Header[i]) eq 'HHMM' then HHMM=Data[i,*]
  if strupcase(Header[i]) eq 'SWDOWN' then begin
   SWdown=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'SWdown,'
   endif
  if strupcase(Header[i]) eq 'LWDOWN' then begin
   LWdown=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'LWdown,'
   endif
  if strupcase(Header[i]) eq 'RAINF' then begin
   Rainf=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Rainf,'
   endif
  if strupcase(Header[i]) eq 'TAIR' then begin
   Tair=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Tair,'
   endif
  if strupcase(Header[i]) eq 'RH' then begin
   RH=Data[i,*]
   endif
  if strupcase(Header[i]) eq 'PSURF' then begin
   PSurf=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'PSurf,'
   endif
  if strupcase(Header[i]) eq 'WS' then begin
   WS=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'WS,'
   endif
  if strupcase(Header[i]) eq 'CO2' then begin
   CO2=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'CO2air,'
   endif
  if strupcase(Header[i]) eq 'FN' then begin
   Fn=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Fn,'
   endif
  if strupcase(Header[i]) eq 'FE' then begin
   Fe=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Fe,'
   endif
  if strupcase(Header[i]) eq 'FH' then begin
   Fh=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Fh,'
   endif
  if strupcase(Header[i]) eq 'FC' then begin
   Fc=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Fc,'
   endif
  if strupcase(Header[i]) eq 'SWS10' then begin
   Sws10=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Sws10,'
   endif
  if strupcase(Header[i]) eq 'TSOIL' then begin
   Tsoil=Data[i,*]
   nVars=nVars+1
   VarList=VarList+'Tsoil,'
   endif
 endfor
; *** Get the elapsed time in seconds.
 print,'nc_ingest2: Calculating elapsed seconds'
 SYear=Year[0] & SMonth=Month[0] & SDay=Day[0]
 Hour=float(fix(HHMM/100.))
 Minute=HHMM-Hour*100
 Second=Minute*0.
 Hh=Hour+Minute/60.+Second/3600.
 SHour=Hour[0] & SMinute=Minute[0] & SSecond=Second[0]
 jdcnv,Year[0],Month[0],Day[0],Hh[0],SJDay
 jdcnv,Year,Month,Day,Hh,JDay
 EJDay=JDay-SJDay
 ElapsedTime=EJDay*86400.
 StartDate=string(SYear,format='(I4)')+'-'+string(SMonth,format='(I2.2)')+'-'+string(SDay,format='(I2.2)')
 StartTime=string(SHour,format='(I2.2)')+':'+string(SMinute,format='(I2.2)')+':'+string(SSecond,format='(I2.2)')
 StartDateTime=StartDate+' '+StartTime
; *** Calculate derived quantities and adjust units as required.
 print,'nc_ingest2: Calculating derived quantities'
 Rainf=Rainf/(TimeStep*60.)    ; mm/timestep to mm/s
 Snowf=Rainf*0.                ; Snowfall
 nVars=nVars+1
 VarList=VarList+'Snowf,'
 e=es(Tair)*RH                 ; Vapour pressure
 Qair=6.22*e/(PSurf-0.00378*e) ; Specific humidity, g/kg
 Qair=Qair/1000.               ; g/kg to kg/kg
 nVars=nVars+1
 VarList=VarList+'Qair,'
 Tair=Tair+273.15              ; C to K
 p=PSurf*100                   ; hPa to Pa
 CO2=CO2*8.315*Tair/(p*0.044)  ; ppm=mg/m3*(RT/p*MW)
 if (writeLAI eq 1) then begin
  LAI=-0.75*sin(2*!PI*(EJDay+16.8)/365)+1.55
  LAI=EJDay*0.0+1.4
  nVars=nVars+1
  VarList=VarList+'LAI,'
 endif
 if (writefrac4 eq 1) then begin
  frac4=-0.23*sin(2*!PI*(EJDay+4.4)/365)+0.37
  frac4=EJDay*0.0+0.39
  nVars=nVars+1
  VarList=VarList+'frac4,'
 endif
 VarList=strmid(VarList,1,strlen(VarList)-2)
; *** Set the dimension values for the netCDF file.  Bit of jiggery-pokery
; *** required here because some input variables for CABLE are defined as
; *** having 3 dimensions(eg SWdown), others four (eg Tair, Qair).
 print,'nc_ingest2: Setting dimensions'
 nDims=4            ; Number of dimensions
 nXDims=1           ; Size of the 'x' dimension
 nYDims=1           ; Size of the 'y' dimension
 nZDims=1           ; Size of the 'z' dimension
 nVAtts=3           ; Maximum number of attributes per variable
; *** Declare the structure used to pass the data, names, dimensions
; *** and attributes to the procedure that writes the netCDF file.
 print,'nc_ingest2: Creating netCDF data structure'
 nc={NGAtt:4,GAttName:strarr(4),GAttValue:strarr(4),$
     NDim:nDims,DimName:strarr(nDims),DimSize:intarr(nDims),$
     NVar:nVars,VarName:strarr(nVars),VarValue:fltarr(nVars,nXDims,nYDims,nZDims,nTimeSteps),$
     VarDimName:strarr(nVars,nDims),$
     NVAtt:nVAtts,VarAttName:strarr(nVars,nVAtts),VarAttValue:strarr(nVars,nVAtts)}
; *** Set up the global attributes.
 print,'nc_ingest2: Setting global attributes in nc structure'
 nc.GAttName[0]='Production'    & nc.GAttValue[0]='Today Now'
 nc.GAttName[1]='Contact'       & nc.GAttValue[1]='muggins@mydomain'
 nc.GAttName[2]='SiteName'      & nc.GAttValue[2]='This place'
 nc.GAttName[3]='DataSetLength' & nc.GAttValue[3]='Many years'
; *** Now set up the dimensions.
 print,'nc_ingest2: Setting dimension values in nc structure'
 nc.DimName[0]='x' & nc.DimSize[0]=nXDims
 nc.DimName[1]='y' & nc.DimSize[1]=nYDims
 nc.DimName[2]='z' & nc.DimSize[2]=nZDims
 nc.DimName[3]='t' & nc.DimSize[3]=0   ; We use a value of 0 to flag the unlimited dimension
; *** Set up the site data that is not contained in the ASCII data file.
 print,'nc_ingest2: Setting site data and times in nc structure'
 k=0
 nc.VarName[k]='longitude'
 nc.VarDimName[k,0]='x'
 nc.VarDimName[k,1]='y'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Longitude'
 nc.VarAttName[k,1]='units' & nc.VarAttValue[k,1]='degrees_east'
 nc.VarValue[k,0,0,0,0]=longitude
 k=k+1
 nc.VarName[k]='latitude'
 nc.VarDimName[k,0]='x'
 nc.VarDimName[k,1]='y'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Latitude'
 nc.VarAttName[k,1]='units' & nc.VarAttValue[k,1]='degrees_north'
 nc.VarValue[k,0,0,0,0]=latitude
 k=k+1
 nc.VarName[k]='isoil'
 nc.VarDimName[k,0]='x'
 nc.VarDimName[k,1]='y'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Soil type (Zobler)'
 nc.VarAttName[k,1]='units' & nc.VarAttValue[k,1]='-'
 nc.VarValue[k,0,0,0,0]=isoil
 k=k+1
 nc.VarName[k]='iveg'
 nc.VarDimName[k,0]='x'
 nc.VarDimName[k,1]='y'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Vegetation type (Potter et al)'
 nc.VarAttName[k,1]='units' & nc.VarAttValue[k,1]='-'
 nc.VarValue[k,0,0,0,0]=iveg
 k=k+1
 nc.VarName[k]='x'
 nc.VarDimName[k,0]='x'
 nc.VarValue[k,0,0,0,0]=1
 k=k+1
 nc.VarName[k]='y'
 nc.VarDimName[k,0]='y'
 nc.VarValue[k,0,0,0,0]=1
 k=k+1
 nc.VarName[k]='elevation'
 nc.VarDimName[k,0]='z'
 nc.VarValue[k,0,0,0,0]=1
 k=k+1
 nc.VarName[k]='time'
 nc.VarDimName[k,0]='t'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Time'
 nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='seconds since '+StartDateTime
 nc.VarValue[k,0,0,0,*]=ElapsedTime
 k=k+1
 nc.VarName[k]='timestp'
 nc.VarDimName[k,0]='t'
 nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Timesteps'
 nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='timesteps since '+StartDateTime
 nc.VarValue[k,0,0,0,*]=findgen(nTimeSteps)
; *** Now work our way through the data to set up the variable-related
; *** fields in the structure.
 print,'nc_ingest2: Setting data values in nc structure'
 VarList=strcompress(VarList,/remove_all)
 Var2Out=strsplit(VarList,',',/extract,count=nVar2Out)
 for i=0,nVar2Out-1 do begin
  if strupcase(Var2Out[i]) eq 'SWDOWN' then begin
    k=k+1
    nc.VarName[k]='SWdown'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Surface incident shortwave radiation'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='W/m^2'
    nc.VarValue[k,0,0,0,*]=SWdown
    endif
  if strupcase(Var2Out[i]) eq 'LWDOWN' then begin
    k=k+1
    nc.VarName[k]='LWdown'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Surface incident longwave radiation'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='W/m^2'
    nc.VarValue[k,0,0,0,*]=LWdown
    endif
  if strupcase(Var2Out[i]) eq 'RAINF' then begin
    k=k+1
    nc.VarName[k]='Rainf'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Rainfall rate'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='mm/s'
    nc.VarValue[k,0,0,0,*]=Rainf
    endif
  if strupcase(Var2Out[i]) eq 'SNOWF' then begin
    k=k+1
    nc.VarName[k]='Snowf'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Snowfall rate'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='mm/s'
    nc.VarValue[k,0,0,0,*]=Snowf
    endif
  if strupcase(Var2Out[i]) eq 'TAIR' then begin
    k=k+1
    nc.VarName[k]='Tair'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Near surface air temperature'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='K'
    nc.VarValue[k,0,0,0,*]=Tair
    endif
  if strupcase(Var2Out[i]) eq 'QAIR' then begin
    k=k+1
    nc.VarName[k]='Qair'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Near surface specific humidity'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='kg/kg'
    nc.VarValue[k,0,0,0,*]=Qair
    endif
  if strupcase(Var2Out[i]) eq 'PSURF' then begin
    k=k+1
    nc.VarName[k]='PSurf'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Surface pressure'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='mb'
    nc.VarValue[k,0,0,0,*]=PSurf
    endif
  if strupcase(Var2Out[i]) eq 'WS' then begin
    k=k+1
    nc.VarName[k]='Wind'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Wind speed'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='m/s'
    nc.VarValue[k,0,0,0,*]=WS
    endif
  if strupcase(Var2Out[i]) eq 'CO2AIR' then begin
    k=k+1
    nc.VarName[k]='CO2air'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='CO2 concentration'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='ppm'
    nc.VarValue[k,0,0,0,*]=CO2
    endif
  if strupcase(Var2Out[i]) eq 'FN' then begin
    k=k+1
    nc.VarName[k]='Fn'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Net radiation'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='W/m^2'
    nc.VarValue[k,0,0,0,*]=Fn
    endif
  if strupcase(Var2Out[i]) eq 'FE' then begin
    k=k+1
    nc.VarName[k]='Fe'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Latent heat flux'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='W/m^2'
    nc.VarValue[k,0,0,0,*]=Fe
    endif
  if strupcase(Var2Out[i]) eq 'FH' then begin
    k=k+1
    nc.VarName[k]='Fh'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Sensible heat flux'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='W/m^2'
    nc.VarValue[k,0,0,0,*]=Fh
    endif
  if strupcase(Var2Out[i]) eq 'FC' then begin
    k=k+1
    nc.VarName[k]='Fc'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='CO2 flux'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='umol/m^2/s'
    nc.VarValue[k,0,0,0,*]=Fc
    endif
  if strupcase(Var2Out[i]) eq 'SWS10' then begin
    k=k+1
    nc.VarName[k]='Sws10'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Soil water content'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='m^3/m^3'
    nc.VarValue[k,0,0,0,*]=Sws10
    endif
  if strupcase(Var2Out[i]) eq 'TSOIL' then begin
    k=k+1
    nc.VarName[k]='Tsoil'
    nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='z' & nc.VarDimName[k,3]='t'
    nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Soil temperature'
    nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='C'
    nc.VarValue[k,0,0,0,*]=Tsoil
    endif
  if strupcase(Var2Out[i]) eq 'LAI' then begin
    if (writeLAI eq 1) then begin
     k=k+1
     nc.VarName[k]='LAI'
     nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
     nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='Leaf area index'
     nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='-'
     nc.VarValue[k,0,0,0,*]=LAI
     endif
    endif
  if strupcase(Var2Out[i]) eq 'FRAC4' then begin
    if (writefrac4 eq 1) then begin
     k=k+1
     nc.VarName[k]='frac4'
     nc.VarDimName[k,0]='x' & nc.VarDimName[k,1]='y' & nc.VarDimName[k,2]='t'
     nc.VarAttName[k,0]='long_name' & nc.VarAttValue[k,0]='C4 fraction'
     nc.VarAttName[k,1]='units'     & nc.VarAttValue[k,1]='-'
     nc.VarValue[k,0,0,0,*]=frac4
     endif
    endif
 endfor
; *** Write the netCDF file.
; *** Create the netCDF file and get the netCDF ID.
 print,'nc_ingest2: Creating the netCDF file'
 ncid=ncdf_create(NCFile,/clobber)
; *** Write the global attributes to the netCDF file.
 print,'nc_ingest2: Writing global attributes to netCDF file'
 for i=0,nc.NGAtt-1 do begin
  ncdf_attput, ncid, nc.GAttName[i], nc.GAttValue[i], /global
 endfor
; *** Define the dimensions.  If the size of a dimension is less than
; *** or equal to zero, that dimension is defined as unlimited.
 print,'nc_ingest2: Writing dimensions to netCDF file'
 DimID=make_array(nc.NDim,/int)
 for i=0,nc.NDim-1 do begin
  if (nc.DimSize[i] gt 0) then $
   DimID[i]=ncdf_dimdef(ncid,nc.DimName[i],nc.DimSize[i]) $
  else $
   DimID[i]=ncdf_dimdef(ncid,nc.DimName[i],/unlimited)
 endfor
; *** Define the variables.
 print,'nc_ingest2: Defining variables for netCDF file'
 VarID=make_array(nc.NVar,/int)
 for i=0,nc.NVar-1 do begin
;for i=0,7 do begin
  for j=0,nc.NDim-1 do begin
   if (strlen(nc.VarDimName[i,j]) eq 1) then begin
    Index=where(nc.DimName eq nc.VarDimName[i,j],count)
    if (count eq 1) then begin
     if (j eq 0) then VarDimID=Index else VarDimID=[VarDimID,Index]
    endif else begin
     print,'write_nc: count ne 1'
     stop
    endelse
   endif
  endfor
  VarID[i]=ncdf_vardef(ncid,nc.VarName[i],VarDimID)
  for j=0,nc.NVAtt-1 do begin
   if (strlen(nc.VarAttName[i,j]) ne 0) then $
    ncdf_attput, ncid, VarID[i], nc.VarAttName[i,j], nc.VarAttValue[i,j]
  endfor
 endfor
; *** Take the netCDF file out of define mode and into data mode.
 print,'nc_ingest2: Taking netCDF file out of define mode'
 ncdf_control, ncid, /endef
; *** Put the variables and attributes into the netCDF file.
 print,'nc_ingest2: Writing variable values and attributes to netCDF file'
for i=0,nc.NVar-1 do begin
 case strupcase(nc.VarName[i]) of
  'LONGITUDE': ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'LATITUDE' : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'ISOIL'    : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'IVEG'     : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'X'        : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'Y'        : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'Z'        : ncdf_varput, ncid, VarID[i], nc.VarValue[i,0,0,0,0]
  'TIME'     : begin
    Value=make_array(nTimeSteps,/float)
    Value=reform(nc.VarValue[i,0,0,0,*],nTimeSteps)
    print,size(Value)
    print,VarID[i]
    ncdf_varput, ncid, VarID[i], Value
    end
  'TIMESTEP' : begin
    Value=make_array(nTimeSteps,/float)
    Value=reform(nc.VarValue[i,0,0,0,*],nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'SWDOWN'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'LWDOWN'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'RAINF'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'SNOWF'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'TAIR'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'QAIR'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'PSURF'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'WIND'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'CO2AIR'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'FE'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'FH'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'FC'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'FN'   : begin
    Value=make_array(nXDims,nYDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'SWS10'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'TSOIL'   : begin
    Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
    Value=reform(nc.VarValue[i,*,*,*,*],nXDims,nYDims,nZDims,nTimeSteps)
    ncdf_varput, ncid, VarID[i], Value
    end
  'LAI'   : begin
    if (writeLAI eq 1) then begin
     Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
     Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
     ncdf_varput, ncid, VarID[i], Value
    endif
    end
  'FRAC4'   : begin
    if (writefrac4 eq 1) then begin
     Value=make_array(nXDims,nYDims,nZDims,nTimeSteps,/float)
     Value=reform(nc.VarValue[i,*,*,0,*],nXDims,nYDims,nTimeSteps)
     ncdf_varput, ncid, VarID[i], Value
    endif
    end
  else:
 endcase
endfor

; *** Close the netCDF file.
 ncdf_close, ncid

 print,'nc_ingest2: All done'

end