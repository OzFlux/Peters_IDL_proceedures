pro writetob1, OutFile, Header, Time, Data

DataSize = size(Data)
NumRecords = DataSize[2]
NumDataFields = DataSize[1]
openw, OutLUN, OutFile, /BINARY, /NOAUTOMODE, /GET_LUN
for i = 0, 4 do writeu, OutLUN, Header[i], string([13B,10B])
for i = 0, NumRecords-1 do begin
 for j = 0, 2 do writeu, OutLUN, Time[j,i]
 for j = 0, NumDataFields-1 do writeu, OutLUN, Data[j,i]
 endfor
free_lun, OutLUN

end