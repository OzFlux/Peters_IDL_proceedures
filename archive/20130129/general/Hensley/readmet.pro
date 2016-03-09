function readmet, filename

 nLines = file_lines(filename)
 HeaderLine = ""
 openr, lun, filename, /get_lun
 readf, lun, HeaderLine
 HeaderParts = strsplit(HeaderLine, ',', /extract)
 nCols = n_elements(HeaderParts)
 data = fltarr(nCols, nLines-1)
 readf, lun, data
 free_lun, lun

 a = {Year:intarr(nLines),Month:intarr(nLines),Day:intarr(nLines),$
      HHMM:intarr(nLines),Hour:intarr(nLines),Minute:intarr(nLines),$
      Fn:fltarr(nLines),Fh:fltarr(nLines),Fe:fltarr(nLines),Fc:fltarr(nLines),$
      Ta:fltarr(nLines),ps:fltarr(nLines),RH:fltarr(nLines),WS:fltarr(nLines),$
      Fsd:fltarr(nLines)}

 for i = 0,n_elements(HeaderParts)-1 do begin
  case HeaderParts[i] of
   'Year': a.Year = fix(reform(data[i,*])+0.5)
   'Month': a.Month = fix(reform(data[i,*])+0.5)
   'Day': a.Day = fix(reform(data[i,*])+0.5)
   'HHMM': a.HHMM = fix(reform(data[i,*])+0.5)
   'Fn': a.Fn = reform(data[i,*])
   'Fe': a.Fe = reform(data[i,*])
   'Fh': a.Fh = reform(data[i,*])
   'Fc': a.Fc = reform(data[i,*])
   'Tair': a.Ta = reform(data[i,*])
   'ps': a.ps = reform(data[i,*])
   'RH': a.RH = reform(data[i,*])
   'WS': a.WS = reform(data[i,*])
   'SWdown': a.Fsd = reform(data[i,*])
  else:
  endcase
 endfor
 a.Hour = fix(a.HHMM/100)
 a.Minute = fix(a.HHMM - a.Hour*100)
 return, a
end