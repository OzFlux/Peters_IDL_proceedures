FUNCTION read_dap_MCD43A4,url,sites
;
; PURPOSE
;  Reads the aggregated MCD43A4 MODIS product available on the AusCover
;  OPeNDAP server.
; USAGE
;  data = read_dap_MCD43A4(url,sites)
; OUTPUT
;  data is an array of IDL/GDL structures, each structure is defined as follows:
;   new = {name:<string>,year:<intarr>,month:<intarr>,day:<intarr>,$
;          hour:<intarr>,minute:<intarr>,second:<intarr>,$
;          nbar_0459_0479nm:<fltarr>,$
;          nbar_0545_0565nm:<fltarr>,$
;          nbar_0620_0670nm:<fltarr>,$
;          nbar_0841_0876nm:<fltarr>,$
;          nbar_1230_1250nm:<fltarr>,$
;          nbar_1628_1652nm:<fltarr>,$
;          nbar_2105_2155nm:<fltarr>,$
;          quality:<intarr>,snow:<intarr>,$
;          typical_mask:<intarr>}
;
; INPUT
;  url is the URL of the file on the AusCover OPeNDAP server
;  sites is an IDL/GDL structure defined as follows:
;  sites = {name:[<array of site names (string)>],$
;           latitude:[<array of latitudes (float)>],$
;           longitude:[<array of longitudes (float)>]}
; AUTHOR: PRI
; DATE: March 2016
;
; open the DAP file
 dap_file = ncdf_open(url)
; get the latitude and longitude resolutions from the global attributes
 ncdf_attget,dap_file,"geospatial_lat_resolution",lat_res,/global
 ncdf_attget,dap_file,"geospatial_lon_resolution",lon_res,/global
; get the time variable
 time_id = ncdf_varid(dap_file,"time")
 ncdf_varget,dap_file,time_id,time
 nrecs = n_elements(time)
; and the time variable units attribute
 ncdf_attget,dap_file,time_id,"units",value
 time_units = string(value)
; get the year, month and day from the time units string
 result = strsplit(time_units," ",/extract)
 ymd = strsplit(result[2],"-",/extract)
; get the hour, minute and seconds
 hms = strsplit(result[3],":",/extract)
; get the Julian date from the netCDF time
 jul_time = time + JulDay(fix(ymd[1]),fix(ymd[2]),fix(ymd[0]),0,0,0)
; ... and get the year, month, day etc from the Julian date
 CalDat, jul_time, month, day, year, hour, minute, second
;print, year[-1], month[-1], day[-1], hour[-1], minute[-1], second[-1]
; get the latitude and longitude variables from the netCDF file
 lat_id = ncdf_varid(dap_file,"latitude")
 ncdf_varget,dap_file,lat_id,latitude
 lon_id = ncdf_varid(dap_file,"longitude")
 ncdf_varget,dap_file,lon_id,longitude
; NOTE: AusCover DAP files are dimensioned as [longitude,latitude,time]
;                                          eg [19160,14902,365]
 nsites = n_elements(sites.name)
 for i=0,nsites-1 do begin
   print,"Processing site: ",sites.name[i]
; get the latitude and longitude indices
   lat_index = fix(((latitude[0]-sites.latitude[i])/lat_res)+0.5)
   if sites.longitude[i]<0 then sites.longitude[i] = float(360) + sites.longitude[i]
   lon_index = fix(((sites.longitude[i]-longitude[0])/lon_res)+0.5)
; get the offset and count for the data subset
   offset = [lon_index-1,lat_index-1,0]
   count = [3,3,nrecs]
; and now get the BDRF reflectance data
; 459 to 479 nm
   id = ncdf_varid(dap_file,"nbar_0459_0479nm")
   ncdf_varget,dap_file,id,nbar_0459_0479nm,offset=offset,count=count
; 545 to 565 nm
   id = ncdf_varid(dap_file,"nbar_0545_0565nm")
   ncdf_varget,dap_file,id,nbar_0545_0565nm,offset=offset,count=count
; 620 to 670 nm
   id = ncdf_varid(dap_file,"nbar_0620_0670nm")
   ncdf_varget,dap_file,id,nbar_0620_0670nm,offset=offset,count=count
; 841 to 876 nm
   id = ncdf_varid(dap_file,"nbar_0841_0876nm")
   ncdf_varget,dap_file,id,nbar_0841_0876nm,offset=offset,count=count
; 1230 to 1250 nm
   id = ncdf_varid(dap_file,"nbar_1230_1250nm")
   ncdf_varget,dap_file,id,nbar_1230_1250nm,offset=offset,count=count
; 1628 to 1652 nm
   id = ncdf_varid(dap_file,"nbar_1628_1652nm")
   ncdf_varget,dap_file,id,nbar_1628_1652nm,offset=offset,count=count
; 2105 to 2155 nm
   id = ncdf_varid(dap_file,"nbar_2105_2155nm")
   ncdf_varget,dap_file,id,nbar_2105_2155nm,offset=offset,count=count
; quality flag
   id = ncdf_varid(dap_file,"quality")
   ncdf_varget,dap_file,id,quality,offset=offset,count=count
; snow
   id = ncdf_varid(dap_file,"snow")
   ncdf_varget,dap_file,id,snow,offset=offset,count=count
; typical mask
   id = ncdf_varid(dap_file,"typical_mask")
   ncdf_varget,dap_file,id,typical_mask,offset=offset,count=count
; create the data structure
   new = {name:sites.name[i],year:year,month:month,day:day,$
          hour:hour,minute:minute,second:second,$
          nbar_0459_0479nm:nbar_0459_0479nm,$
          nbar_0545_0565nm:nbar_0545_0565nm,$
          nbar_0620_0670nm:nbar_0620_0670nm,$
          nbar_0841_0876nm:nbar_0841_0876nm,$
          nbar_1230_1250nm:nbar_1230_1250nm,$
          nbar_1628_1652nm:nbar_1628_1652nm,$
          nbar_2105_2155nm:nbar_2105_2155nm,$
          quality:quality,snow:snow,$
          typical_mask:typical_mask}
; add this structure to the array
   if i eq 0 then data = replicate(new,nsites) else data[i] = new
 endfor
; close the netCDF file
 ncdf_close,dap_file
; return the data structure
 return,data
END