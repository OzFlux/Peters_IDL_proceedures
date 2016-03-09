function read_netcdf_attr, nc_file_name
; open the netCDF file
 nc_file = ncdf_open(nc_file_name)

; get some essential metadata
; this is the site name
 ncdf_attget, nc_file, /GLOBAL, 'site_name', value
 site_name = string(value)
; this is the time step (either 30 or 60)
 ncdf_attget, nc_file, /GLOBAL, 'time_step', value
 time_step = fix(string(value))
; this is the date and time when the netCDF file was generated
 ncdf_attget, nc_file, /GLOBAL, 'nc_rundatetime', value
 nc_rundatetime = string(value)
; this is the version of OzFluxQC used to generate the netCDF file
 ncdf_attget, nc_file, /GLOBAL, 'QC_version', value
 QC_version = string(value)
; this is the number of records inn the netCDF file
 ncdf_attget, nc_file, /GLOBAL, 'nc_nrecs', value
 nrecs = fix(string(value))

; close the netCDF file
 ncdf_close, nc_file

; create the attribute structure
 my_attr = {nrecs:nrecs,site_name:site_name,time_step:time_step,$
            nc_rundatetime:nc_rundatetime,QC_version:QC_version}

; return the attribute structure
 return, my_attr
end