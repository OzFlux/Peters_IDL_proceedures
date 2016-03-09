function readtowerheader, filename

 nLines = file_lines(filename)
 HeaderLine = ''
 openr, lun, filename, /get_lun
 readf, lun, HeaderLine
 HeaderParts = strsplit(HeaderLine, ',', /extract)
 nCols = n_elements(HeaderParts)
 name = strarr (1, nLines-1)
 dat = dblarr(nCols-1, nLines-1)

;WHILE (NOT EOF(lun)) DO BEGIN
 readf, lun, name, dat
 free_lun, lun
;ENDWHILE

Tower = {Site:strarr(nLines-1),Latitude:dblarr(nLines-1),Longitude:dblarr(nLines-1),$
		elev:fltarr(nLines-1),h:fltarr(nLines-1), z_ref:fltarr(nLines-1)}

for i = 0L,nCols-1 do begin
  case HeaderParts[i] of
   'Site'	: Tower.Site = reform(name[i,*]); Site name
   'Latitude':Tower.Latitude = reform(dat[i,*])
   'Longitude':Tower.Longitude = reform(dat[i,*])
   'elev'	:Tower.elev = reform(dat[i,*]);elevation of base of tower
   'h'		:Tower.h = reform(dat[i,*]) ;canopy height
   'z_ref'	:Tower.z_ref = reform(dat[i,*]) ; measurement height
  else:
  endcase
endfor
print, Tower.Site(1)
return, Tower

END