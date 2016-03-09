pro hs_ebal_gaps


InFilePath=getenv('InFilePath')
if strlen(inFilePath) eq 0 then $
 InFileName=Dialog_PickFile(TITLE='Select input file',GET_PATH=InFilePath) $
else $
 InFileName=Dialog_PickFile(TITLE='Select input file',PATH=InFilePath,GET_PATH=InFilePath)
if (strlen(InFileName) eq 0) then goto, finish
setenv, 'InFilePath='+InFilePath

openr,InLUN,InFileName,/get_lun
nTimeSteps=numlines(InLUN)-1
; *** Read the header line.
HeaderLine=''
readf,InLUN,HeaderLine
; *** Separate out the variables.
VarNames=strsplit(HeaderLine,',',/extract,count=nVars)
; *** Read the data.
Data=fltarr(nVars,nTimeSteps)
readf, InLUN, Data
free_lun, InLUN
; *** Get the output file name.
PathLen=strlen(InFilePath)
DotPos=rstrpos(InFileName,'.')
BaseName = strmid(InFileName, PathLen, DotPos-PathLen)
OutFileName=InFilePath+BaseName+'_gaps.txt'
; *** Open the output file.
openw,OutLUN,OutFileName,/get_lun

; *** Get data into individual series.
for i=0,nVars-1 do begin
 case strupcase(VarNames[i]) of
  'YR'    : Year=Data[i,*]
  'MO'    : Month=Data[i,*]
  'DY'    : Day=Data[i,*]
  'HR'    : Hour=Data[i,*]
  'MI'    : Minute=Data[i,*]
  'RN_AVG': Fn=Data[i,*]
  'SHFP1' : Fg1=Data[i,*]
  'SHFP2' : Fg2=Data[i,*]
  'SHFP3' : Fg3=Data[i,*]
  'SHFP4' : Fg4=Data[i,*]
  'DEL_TSOIL(1)' : DTs1=Data[i,*]
  'DEL_TSOIL(2)' : DTs2=Data[i,*]
  'SWC_T10A_AVG' : Sws10a=Data[i,*]    ; Storage, water, soil, 10cm, a
  'SWC_T10B_AVG' : Sws10b=Data[i,*]    ; Storage, water, soil, 10cm, b
  'SWC_T40_AVG'  : Sws40=Data[i,*]     ; Storage, water, soil, 40cm
  'SWC_T100_AVG' : Sws100=Data[i,*]    ; Storage, water, soil, 100cm
  'TSOIL_AVG(1)' : Ts1=Data[i,*]       ; Temperature, soil, 1
  'TSOIL_AVG(2)' : Ts2=Data[i,*]       ; Temperature, soil, 2
  'KDOWN_AVG'    : Fsd=Data[i,*]       ; Flux, shortwave, down
  'KUP_AVG'      : Fsu=Data[i,*]       ; Flux, shortwave, up
  'LDOWN_AVG'    : Fld=Data[i,*]       ; Flux, longwave, down
  'LUP_AVG'      : Flu=Data[i,*]       ; Flux, longwave, up
  'RAIN_TOT'     : Pr=Data[i,*]        ; Precipitation, rain
  else: print,'Variable ',strcompress(VarNames[i],/remove_all),' found in file but not treated'
  endcase
 endfor
; *** Calculate the percentage of missing data.
nInMonth=make_array(12,/long)
FnMiss=make_array(13,/float)      ; Net radiation
Fg1Miss=make_array(13,/float)     ; Ground heat flux
Fg2Miss=make_array(13,/float)     ; Ground heat flux
Fg3Miss=make_array(13,/float)     ; Ground heat flux
Fg4Miss=make_array(13,/float)     ; Ground heat flux
DTs1Miss=make_array(13,/float)    ;
DTs2Miss=make_array(13,/float)    ;
Sws10aMiss=make_array(13,/float)  ;
Sws10bMiss=make_array(13,/float)  ;
Sws40Miss=make_array(13,/float)   ;
Sws100Miss=make_array(13,/float)  ;
Ts1Miss=make_array(13,/float)     ;
Ts2Miss=make_array(13,/float)     ;
FsdMiss=make_array(13,/float)     ;
FsuMiss=make_array(13,/float)     ;
FldMiss=make_array(13,/float)     ;
FluMiss=make_array(13,/float)     ;
PrMiss=make_array(13,/float)      ;
print,'Mo','Fn','Fg1','Fg2','Fg3','Fg4','DTs1','DTs2','Sws10a','Sws10b','Sws40','Sws100','Ts1','Ts2',$
 'Fsd','Fsu','Fld','Flu','Pr',format='(19A7)'
printf,OutLUN,'Mo','Fn','Fg1','Fg2','Fg3','Fg4','DTs1','DTs2','Sws10a','Sws10b','Sws40','Sws100','Ts1','Ts2',$
 'Fsd','Fsu','Fld','Flu','Pr',format='(19A7)'
for i=0,11 do begin
 MnthIndx=where(Month eq i+1, count)
 if (count ne 0) then begin
  nInMonth[i]=count
  Index=where(Fn[MnthIndx] eq -9999, count) & FnMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fg1[MnthIndx] eq -9999, count) & Fg1Miss[i]=float(count*100/nInMonth[i])
  Index=where(Fg2[MnthIndx] eq -9999, count) & Fg2Miss[i]=float(count*100/nInMonth[i])
  Index=where(Fg3[MnthIndx] eq -9999, count) & Fg3Miss[i]=float(count*100/nInMonth[i])
  Index=where(Fg4[MnthIndx] eq -9999, count) & Fg4Miss[i]=float(count*100/nInMonth[i])
  Index=where(DTs1[MnthIndx] eq -9999, count) & DTs1Miss[i]=float(count*100/nInMonth[i])
  Index=where(DTs2[MnthIndx] eq -9999, count) & DTs2Miss[i]=float(count*100/nInMonth[i])
  Index=where(Sws10a[MnthIndx] eq -9999, count) & Sws10aMiss[i]=float(count*100/nInMonth[i])
  Index=where(Sws10b[MnthIndx] eq -9999, count) & Sws10bMiss[i]=float(count*100/nInMonth[i])
  Index=where(Sws40[MnthIndx] eq -9999, count) & Sws40Miss[i]=float(count*100/nInMonth[i])
  Index=where(Sws100[MnthIndx] eq -9999, count) & Sws100Miss[i]=float(count*100/nInMonth[i])
  Index=where(Ts1[MnthIndx] eq -9999, count) & Ts1Miss[i]=float(count*100/nInMonth[i])
  Index=where(Ts2[MnthIndx] eq -9999, count) & Ts2Miss[i]=float(count*100/nInMonth[i])
  Index=where(Fsd[MnthIndx] eq -9999, count) & FsdMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fsu[MnthIndx] eq -9999, count) & FsuMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fld[MnthIndx] eq -9999, count) & FldMiss[i]=float(count*100/nInMonth[i])
  Index=where(Flu[MnthIndx] eq -9999, count) & FluMiss[i]=float(count*100/nInMonth[i])
  Index=where(Pr[MnthIndx] eq -9999, count) & PrMiss[i]=float(count*100/nInMonth[i])
 endif else begin
  FnMiss[i]=-99.
  Fg1Miss[i]=-99.
  Fg2Miss[i]=-99.
  Fg3Miss[i]=-99.
  Fg4Miss[i]=-99.
  DTs1Miss[i]=-99.
  DTs2Miss[i]=-99.
  Sws10aMiss[i]=-99.
  Sws10bMiss[i]=-99.
  Sws40Miss[i]=-99.
  Sws100Miss[i]=-99.
  Ts1Miss[i]=-99.
  Ts2Miss[i]=-99.
  FsdMiss[i]=-99.
  FsuMiss[i]=-99.
  FldMiss[i]=-99.
  FluMiss[i]=-99.
  PrMiss[i]=-99.
 endelse
 print, i+1,FnMiss[i],Fg1Miss[i],Fg2Miss[i],Fg3Miss[i],Fg4Miss[i],DTs1Miss[i],DTs2Miss[i],$
  Sws10aMiss[i],Sws10bMiss[i],Sws40Miss[i],Sws100Miss[i],Ts1Miss[i],Ts2Miss[i],$
  FsdMiss[i],FsuMiss[i],FldMiss[i],FluMiss[i],PrMiss[i],format='(19I7)'
 printf,OutLUN, i+1,FnMiss[i],Fg1Miss[i],Fg2Miss[i],Fg3Miss[i],Fg4Miss[i],DTs1Miss[i],DTs2Miss[i],$
  Sws10aMiss[i],Sws10bMiss[i],Sws40Miss[i],Sws100Miss[i],Ts1Miss[i],Ts2Miss[i],$
  FsdMiss[i],FsuMiss[i],FldMiss[i],FluMiss[i],PrMiss[i],format='(19I7)'
endfor
FnMiss[12]=mean(FnMiss[0:11])
Fg1Miss[12]=mean(Fg1Miss[0:11])
Fg2Miss[12]=mean(Fg2Miss[0:11])
Fg3Miss[12]=mean(Fg3Miss[0:11])
Fg4Miss[12]=mean(Fg4Miss[0:11])
DTs1Miss[12]=mean(DTs1Miss[0:11])
DTs2Miss[12]=mean(DTs2Miss[0:11])
Sws10aMiss[12]=mean(Sws10aMiss[0:11])
Sws10bMiss[12]=mean(Sws10bMiss[0:11])
Sws40Miss[12]=mean(Sws40Miss[0:11])
Sws100Miss[12]=mean(Sws100Miss[0:11])
Ts1Miss[12]=mean(Ts1Miss[0:11])
Ts2Miss[12]=mean(Ts2Miss[0:11])
FsdMiss[12]=mean(FsdMiss[0:11])
FsuMiss[12]=mean(FsuMiss[0:11])
FldMiss[12]=mean(FldMiss[0:11])
FluMiss[12]=mean(FluMiss[0:11])
PrMiss[12]=mean(PrMiss[0:11])
print,'Year',FnMiss[12],Fg1Miss[12],Fg2Miss[12],Fg3Miss[12],Fg4Miss[12],DTs1Miss[12],DTs2Miss[12],$
  Sws10aMiss[12],Sws10bMiss[12],Sws40Miss[12],Sws100Miss[12],Ts1Miss[12],Ts2Miss[12],$
  FsdMiss[12],FsuMiss[12],FldMiss[12],FluMiss[12],PrMiss[12],format='(A7,18I7)'
printf,OutLUN,'Year',FnMiss[12],Fg1Miss[12],Fg2Miss[12],Fg3Miss[12],Fg4Miss[12],DTs1Miss[12],DTs2Miss[12],$
  Sws10aMiss[12],Sws10bMiss[12],Sws40Miss[12],Sws100Miss[12],Ts1Miss[12],Ts2Miss[12],$
  FsdMiss[12],FsuMiss[12],FldMiss[12],FluMiss[12],PrMiss[12],format='(A7,18I7)'

finish:
free_lun,OutLUN
end