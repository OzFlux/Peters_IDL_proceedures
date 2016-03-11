pro test_dap_MCD43A4

;  sites = {name:["Calperum","Sturt Plains","Whroo"],$
;           latitude:[-34.00206,-17.15090,-36.67305],$
;           longitude:[140.58912,133.35055,145.02621]}
  sites = {name:["Sturt Plains"],latitude:[-17.15090],longitude:[133.35055]}

; define the DAP URL and the file name
  dap_path = "http://www.auscover.org.au/thredds/dodsC/auscover/lpdaac-aggregates/c5/v2-nc4/aust/MCD43A4.005/"
  file_name = "MCD43A4.aggregated.aust.005.nadir_brdf_adjusted_reflectance.ncml"
; get the full URL and open the netCDF file
  url = dap_path+file_name

  data = read_dap_MCD43A4(url,sites)

  for i=0,n_elements(data)-1 do begin
    nrecs = n_elements(data[i].year)
; get the decimal year for plotting
    julian_date = JulDay(data[i].month,data[i].day,data[i].year,$
                         data[i].hour,data[i].minute,data[i].second)
    doy = julian_date - JulDay(1,1,data[i].year)
    diy = intarr(nrecs)
    diy = 365
    idx = where((data[i].year mod 4) eq 0,count)
    diy[idx] = 366
    ydy = data[i].year + doy/diy + data[i].hour/(24*diy) + data[i].minute/(24*60*diy)
    window,i
    plot,ydy,data[i].nbar_0459_0479nm[1,1,*],max_value=0.2,min_value=0.0,$
         xrange=[2000,2017],xtickinterval=1,$
         xtitle="Years",ytitle="BDRF Reflectance",$
         title=sites.name[i]
    oplot,ydy,data[i].nbar_0459_0479nm[0,0,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[0,1,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[0,2,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[1,0,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[1,2,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[2,0,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[2,1,*],max_value=0.2,min_value=0.0
    oplot,ydy,data[i].nbar_0459_0479nm[2,2,*],max_value=0.2,min_value=0.0
  endfor

end
