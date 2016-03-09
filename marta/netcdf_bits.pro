 ncfile_info = ncdf_inquire(nc_file)
; print the dimensions
; dim_name = ""
; dim_size = ""
; for i = 0, ncfile_info.ndims-1 do begin
;     ncdf_diminq,nc_file,i,dim_name,dim_size
;     print,i," ",dim_name,dim_size
; endfor
; print the variables

time_info = ncdf_varinq(evi_file,time_id)
for i=0,time_info.natts-1 do begin
 name = ncdf_attname(evi_file,time_id,i)
 ncdf_attget,evi_file,time_id,name,value
 print,name,": ",string(value)
endfor