pro write_csv, csv_file_name, my_data

; get a list of tag names from the data structure
 tagnames = tag_names(my_data)
 val = size(tagnames)
 ncols = val[1]
; get the number of records in the data arrays
 nrecs = n_elements(my_data.year)
  
 openw, lun, csv_file_name, /get_lun
 for i=0L,ncols-2 do printf, lun, tagnames[i], FORMAT='(A,",",$)'
 printf, lun, tagnames[ncols-1]

 for i=0L,nrecs-1 do begin
  strline=''
  for j=0L,ncols-1 do begin
;   print,i,j,tagnames[j],my_data.(j)[i]
;   strline += string(my_data.(j)[i])
    case size(my_data.(j), /type) of
      2 : strline += string(my_data.(j)[i], FORMAT='(I0)')
      3 : strline += string(my_data.(j)[i], FORMAT='(I0)')
      4 : strline += string(my_data.(j)[i], FORMAT='(F0.4)')
      5 : strline += string(my_data.(j)[i], FORMAT='(G0.8)')
      7 : strline += string(my_data.(j)[i], FORMAT='(%"%s")')
      12: strline += string(my_data.(j)[i], FORMAT='(I0)')
      13: strline += string(my_data.(j)[i], FORMAT='(I0)')
      14: strline += string(my_data.(j)[i], FORMAT='(I0)')
      15: strline += string(my_data.(j)[i], FORMAT='(I0)')
    endcase
    if j ne ncols-1 then strline += string(',')
  endfor
  printf, lun, strline
 endfor

; for j=0L,ncols-1 do begin
;  print,tagnames[j],size(my_data.(j),/type)
; endfor

 close, lun
 free_lun, lun

end