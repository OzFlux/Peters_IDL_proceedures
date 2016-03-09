pro nc2csv_remote

; get the OPeNDAP URL for the file
 dap_url="http://dap.ozflux.org.au"
 nc_url="/thredds/dodsC/ozflux/sites/Whroo/L6/Whroo_2011_to_2014_L6.nc"
 nc_name = dap_url+nc_url
; get the data
 my_data = read_netcdf_data(nc_name)
 ; get some global attributes
 my_attr = read_netcdf_attr(nc_name)
; get the CSV file name
 csv_name = "Whroo_2011_to_2014_L6.csv"
 write_csv, csv_name, my_data
; do a token plot
 window,0
 plot,my_data.GPP_f

end