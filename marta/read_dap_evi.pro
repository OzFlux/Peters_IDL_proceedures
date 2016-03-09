pro read_dap_evi

 evi_path = "http://www.auscover.org.au/thredds/dodsC/auscover/lpdaac-aggregates/c5/v2-nc4/aust/"
 evi_file = "MOD13Q1.005/MOD13Q1.aggregated.aust.005.enhanced_vegetation_index.ncml"
; get the full URL and open the netCDF file
 nc_full_name = evi_path+evi_file
 nc_file = ncdf_open(nc_full_name)
; get the latitude and longitude resolutions
 ncdf_attget,nc_file,"geospatial_lat_resolution",lat_res,/global
 ncdf_attget,nc_file,"geospatial_lon_resolution",lon_res,/global
; get the time
 time_id = ncdf_varid(nc_file,"time")
 ncdf_varget,nc_file,time_id,time
 nrecs = n_elements(time)
; get the latitude and longitude
 lat_id = ncdf_varid(nc_file,"latitude")
 ncdf_varget,nc_file,lat_id,latitude
 lon_id = ncdf_varid(nc_file,"longitude")
 ncdf_varget,nc_file,lon_id,longitude
; NOTE: evi is dimensioned as [longitude,latitude,time]
;                          eg [19160,14902,365]
; get the latitude and longitude indices
 lat_index = fix(((latitude[0]-site_latitude)/lat_resolution)+0.5)
; if site_longitude<0: site_longitude = float(360) + site_longitude
 lon_index = fix(((site_longitude-longitude[0])/lon_resolution)+0.5)
; get the offset and count for the data subset
 offset = [lon_index-1,lat_index-1,0]
 count = [3,3,nrecs]
 evi_id = ncdf_varid(nc_file,"evi")
 ncdf_varget,nc_file,evi_id,evi,offset=offset,count=count
 
 window,0
 plot,evi,max_value=1.0,min_value=-0.2
 
 ncdf_close,nc_file

end
