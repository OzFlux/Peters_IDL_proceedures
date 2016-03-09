pro nc_list
; PURPOSE
;  Reads a netCDF file and lists the variables in the file to the screen
;  and to a text file.  The variable attributes are also printed.  The
;  text file name is derived from the base name of the input
;  netCDF file name with "_list.txt" appended.
; METHOD
;  Uses the standard netCDF routines available in IDL.
;  Nice bits include the saving of the input file path to an IDL
;  environment variable so that the next call to DIALOG_PICKFILE
;  comes up in the same directory.
; AUTHOR: Peter Isaac
; DATE: 27/08/2007
; VERSION: IDL V5.2+
; MODIFICATIONS
;

 FilePath = '/home/data/ARCSpatial/Sites/HowardSprings/Data/Processed/Misc/'
 FileName = '20040601To20050531'
 lsFile = FilePath+FileName+'.txt'
 ncFile = FilePath+FileName+'.nc'

 ncid=ncdf_open(ncFile)
 inqS=ncdf_inquire(ncid)
 VarNames=strarr(inqS.nvars)

 get_lun,ListLUN
 openw,ListLUN, lsFile

; *** Check for global attributes.
 if (inqS.ngatts ne 0) then begin
  print, ncFile+' contains the following global attributes'
  printf, ListLUN, ncFile+' contains the following global attributes'
  for i=0,inqS.ngatts-1 do begin
   GAttName=ncdf_attname(ncid,i,/global)
   ncdf_attget, ncid, GAttName, GAttValue, /global
   print, i, ' ', GAttName,': ', string(GAttValue),format='(5X,I5,4A)'
   printf, ListLUN, i, ' ', GAttName, ': ', string(GAttValue),format='(5X,I5,4A)'
  endfor
 endif

 print, ncFile+' contains the following dimensions'
 printf, ListLUN, ncFile+' contains the following dimensions'
 DimNames=make_array(inqS.ndims,/string)
 DimSizes=make_array(inqS.ndims,/long)
 for i=0,inqS.ndims-1 do begin
  ncdf_diminq, ncid, i, DimName, DimSize
  DimNames[i]=DimName
  DimSizes[i]=DimSize
; ncdf_diminq, ncid, i, DimNames[i], DimSizes[i]
  print, DimNames[i], DimSizes[i]
  printf, ListLUN, DimNames[i], DimSizes[i]
 endfor

print, ncFile+' contains the following variables'
printf, ListLUN, ncFile+' contains the following variables'
for i=0,inqS.nvars-1 do begin
 varinqS=ncdf_varinq(ncid,i)
 for k=0,varinqS.ndims-1 do begin
  if (k eq 0) then DimNameStr='('
  DimNameStr=DimNameStr+DimNames[varinqS.dim[k]]
  if (k ge 0 and k lt varinqS.ndims-1) then DimNameStr=DimNameStr+','
  if (k eq varinqS.ndims-1) then DimNameStr=DimNameStr+')'
 endfor
 for k=0,varinqS.ndims-1 do begin
  if (k eq 0) then DimSizeStr='('
  DimSizeStr=DimSizeStr+strcompress(string(DimSizes[varinqS.dim[k]]),/remove_all)
  if (k ge 0 and k lt varinqS.ndims-1) then DimSizeStr=DimSizeStr+','
  if (k eq varinqS.ndims-1) then DimSizeStr=DimSizeStr+')'
 endfor
 VarNames[i]=varinqS.name
 print, i,VarNames[i],' : ',DimNameStr,' ',DimSizeStr,format='(I5,1X,5A)'
 printf,ListLUN, i,VarNames[i],' : ',DimNameStr,' ',DimSizeStr,format='(I5,1X,5A)'
 VarNAtt=varinqS.natts
 if VarNAtt ne 0 then begin
  for j=0,VarNAtt-1 do begin
   AttName=ncdf_attname(ncid,i,j)
   attinqS=ncdf_attinq(ncid,i,AttName)
   ncdf_attget, ncid, i, AttName, AttValue
   print, j, ' ', AttName,': ', string(AttValue),format='(5X,I5,4A)'
   printf, ListLUN, j, ' ', AttName, ': ', string(AttValue),format='(5X,I5,4A)'
  endfor
 endif
endfor
print, 'Variable listing written to '+ListFileName
close, ListLUN
free_lun, ListLUN

ncdf_close, ncid

end