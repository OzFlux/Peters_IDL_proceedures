function readmet, filename ; for CSIRO flux data

 nLines = file_lines(filename)
 HeaderLine = ''
 openr, lun, filename, /get_lun
 readf, lun, HeaderLine
 HeaderParts = strsplit(HeaderLine, ',', /extract)
 nCols = n_elements(HeaderParts)
 data = dblarr(nCols, nLines-1)

 readF, lun, data
 free_lun, lun

met = {Latitude: fltarr(nLines-1), Longitude: fltarr(nLines-1), Year:intarr(nLines-1),JD:fltarr(nLines-1),DayofYear:intarr(nLines-1),Hour:fltarr(nLines-1),$
 		ustar:fltarr(nLines-1),windspeed:fltarr(nLines-1),winddir:intarr(nLines-1),$
 		FCO2:fltarr(nLines-1),Fstorage:fltarr(nLines-1),LE_:fltarr(nLines-1),H_:fltarr(nLines-1),Rgin:fltarr(nLines-1),Rgout:fltarr(nLines-1),$
 		LWRin:fltarr(nLines-1),LWRout:fltarr(nLines-1),PARin:fltarr(nLines-1),PARout:fltarr(nLines-1),Rn:fltarr(nLines-1),G:fltarr(nLines-1),$
     	Ts:fltarr(nLines-1),Tc:fltarr(nLines-1),Tair:fltarr(nLines-1),Tsoil:fltarr(nLines-1),RH:fltarr(nLines-1),SWC:fltarr(nLines-1),Rainfall:fltarr(nLines-1),$
     	Pressure:fltarr(nLines-1),EVI:fltarr(nLines-1),NDVI:fltarr(nLines-1),SAVI:fltarr(nLines-1),LSWI:fltarr(nLines-1)}

 for i = 0L,nCols-1 do begin
  case HeaderParts[i] of
   'Latitude':met.Latitude=reform(data[i,*])
   'Longitude':met.Longitude=reform(data[i,*])
   'YEAR'	: met.YEAR = fix(reform(data[i,*])+0.5)
   'JD	'	: met.JD  = reform(data[i,*])
   'DayofYear'	: met.DayofYear = fix(reform(data[i,*])+0.5)
   'Hour'	: met.Hour= reform(data[i,*])
   'ustar'	: met.ustar=reform(data[i,*])
   'windspeed': met.windspeed = reform(data[i,*])
   'winddir': met.winddir = reform(data[i,*])
   'FCO2'	: met.FCO2 = reform(data[i,*])
   'Fstorage': met.Fstorage = reform(data[i,*])
   'LE_'	: met.LE_ = reform(data[i,*])
   'H_'		: met.H_ = reform(data[i,*])
   'Rgin'	: met.Rgin= reform(data[i,*])
   'Rgout'	: met.Rgout= reform(data[i,*])
   'LWRin'	: met.LWRin= reform(data[i,*])
   'LWRout'	: met.LWRout=reform(data[i,*])
   'PARin'	: met.PARin = reform(data[i,*])
   'PARout'	: met.PARout = reform(data[i,*])
   'Rn'		: met.Rn = reform(data[i,*])
   'G'		: met.G = reform(data[i,*])
   'Ts'		: met.Ts = reform(data[i,*])
   'Tc'		: met.Tc = reform(data[i,*])
   'Tair'	: met.Tair = reform(data[i,*])
   'Tsoil'	: met.Tsoil = reform(data[i,*])
   'RH'		: met.RH = reform(data[i,*])
   'SWC'	: met.SWC= reform(data[i,*])
   'Rainfall': met.Rainfall=reform(data[i,*])
   'Pressure': met.Pressure = reform(data[i,*])
   'EVI'	: met.EVI= reform(data[i,*])
   'NDVI'	: met.NDVI= reform(data[i,*])
   'SAVI'	: met.SAVI= reform(data[i,*])
   'LSWI'	: met.LSWI= reform(data[i,*])

  else:
  endcase



 endfor

 return, met

end