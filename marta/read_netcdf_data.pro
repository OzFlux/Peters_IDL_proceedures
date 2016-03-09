function read_netcdf_data, nc_file_name
; open the netCDF file
 nc_file = ncdf_open(nc_file_name)

; read the variables
; here we use the OzFlux standard variable names
 ncdf_varget, nc_file, 'Year', Year
 ncdf_varget, nc_file, 'Month', Month
 ncdf_varget, nc_file, 'Day', Day
 ncdf_varget, nc_file, 'Hour', Hour
 ncdf_varget, nc_file, 'Minute', Minute
 ncdf_varget, nc_file, 'NEE_SOLO', NEE
 ncdf_varget, nc_file, 'GPP_SOLO', GPP
 ncdf_varget, nc_file, 'Ta', Ta
 ncdf_varget, nc_file, 'Ws', Ws
 ncdf_varget, nc_file, 'Fh', Fh
 ncdf_varget, nc_file, 'Fe', Fe
 ncdf_varget, nc_file, 'VPD', VPD
 ncdf_varget, nc_file, 'Fn', Fn
 ncdf_varget, nc_file, 'Precip', Precip
 ncdf_varget, nc_file, 'Fsd', Fsd
 ncdf_varget, nc_file, 'RH', RH

; close the netCDF file
 ncdf_close, nc_file
 
; remove degenerate dimensions
; this is necessary because <V2.8 OzFlux netCDF files have 1 dimension (time)
; but >V2.8 have 3 dimensions (time,latitude,longitude)
 Year = reform(Year)
 Month = reform(Month)
 Day = reform(Day)
 Hour = reform(Hour)
 Minute = reform(Minute)
 NEE = reform(NEE)
 GPP = reform(GPP)
 Ta = reform(Ta)
 Ws = reform(Ws)
 Fh = reform(Fh)
 Fe = reform(Fe)
 VPD = reform(VPD)
 Fn = reform(Fn)
 Precip = reform(Precip)
 Fsd = reform(Fsd)
 RH = reform(RH)

; now get the day of the year
 nrecs = n_elements(Year)
 DoY = make_array(nrecs,/long)
 base_year = Year[0]
 for i=0,nrecs-1 do begin
  if Year[i] ne base_year then base_year = Year[i]
  DoY[i] = fix(julday(Month[i],Day[i],Year[i]) - julday(1,1,base_year) + 1)
 endfor

; create the data structure
; here we map the OzFlux standard variable names to the FluxNet La Thuile variable names
 my_data = {Year:Year,Month:Month,Day:Day,DoY:DoY,Hour:Hour,Minute:Minute,$
            NEE:NEE,GPP_f:GPP,Ta_f:Ta,WS_f:Ws,H_f:Fh,$
            LE_f:Fe,VPD_f:VPD,Rn_f:Fn,Precip_f:Precip,$
            Rg_f:Fsd,Rh:RH}

; return the data structure
 return, my_data
end