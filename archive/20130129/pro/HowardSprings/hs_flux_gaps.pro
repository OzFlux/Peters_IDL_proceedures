pro hs_flux_gaps


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
  'FC_WPL': Fc=Data[i,*]
  'LE_WPL': Fe=Data[i,*]
  'HS'    : Fh=Data[i,*]
  'TAU'   : Fm=Data[i,*]
  'CO2'   : CO2_li75=Data[i,*]
  'H2O'   : H2O_li75=Data[i,*]
  'TS'    : Ta_csat=Data[i,*]
  'PS'    : ps=Data[i,*]
  'CMPS_DIR' : WD=Data[i,*]
  'WS'       : WS=Data[i,*]
  'HMP_E_A'  : H2O_hmp=Data[i,*]
  'HMP_TMP'  : Ta_hmp=Data[i,*]
  else: print,'Variable ',strcompress(VarNames[i],/remove_all),' found in file but not treated'
  endcase
 endfor
; *** Calculate the percentage of missing data.
nInMonth=make_array(12,/long)
FcMiss=make_array(13,/float)      ; CO2 flux
FeMiss=make_array(13,/float)      ; LE
FhMiss=make_array(13,/float)      ; H
FmMiss=make_array(13,/float)      ; tau
C75Miss=make_array(13,/float)     ; CO2 concentration, LI-7500
H75Miss=make_array(13,/float)     ; H2O concentration, LI-7500
TacMiss=make_array(13,/float)     ; Ta, CSAT
psMiss=make_array(13,/float)      ; ps
WDMiss=make_array(13,/float)      ; WD, CSAT
WSMiss=make_array(13,/float)      ; WS, CSAT
HhMiss=make_array(13,/float)      ; H2O, HMP
TahMiss=make_array(13,/float)     ; Ta, HMP
print,'  Mo  Fc  Fe  Fh  Fm C75 H75 Tac  ps  WD  WS  Hh Tah'
printf,OutLUN,'  Mo  Fc  Fe  Fh  Fm C75 H75 Tac  ps  WD  WS  Hh Tah'
for i=0,11 do begin
 MnthIndx=where(Month eq i+1, count)
 if (count ne 0) then begin
  nInMonth[i]=count
  Index=where(Fc[MnthIndx] eq -9999, count) & FcMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fe[MnthIndx] eq -9999, count) & FeMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fh[MnthIndx] eq -9999, count) & FhMiss[i]=float(count*100/nInMonth[i])
  Index=where(Fm[MnthIndx] eq -9999, count) & FmMiss[i]=float(count*100/nInMonth[i])
  Index=where(CO2_li75[MnthIndx] eq -9999, count) & C75Miss[i]=float(count*100/nInMonth[i])
  Index=where(H2O_li75[MnthIndx] eq -9999, count) & H75Miss[i]=float(count*100/nInMonth[i])
  Index=where(Ta_csat[MnthIndx] eq -9999, count) & TacMiss[i]=float(count*100/nInMonth[i])
  Index=where(ps[MnthIndx] eq -9999, count) & psMiss[i]=float(count*100/nInMonth[i])
  Index=where(WD[MnthIndx] eq -9999, count) & WDMiss[i]=float(count*100/nInMonth[i])
  Index=where(WS[MnthIndx] eq -9999, count) & WSMiss[i]=float(count*100/nInMonth[i])
  Index=where(H2O_hmp[MnthIndx] eq -9999, count) & HhMiss[i]=float(count*100/nInMonth[i])
  Index=where(Ta_hmp[MnthIndx] eq -9999, count) & TahMiss[i]=float(count*100/nInMonth[i])
 endif else begin
  FcMiss[i]=-99.
  FeMiss[i]=-99.
  FhMiss[i]=-99.
  FmMiss[i]=-99.
  C75Miss[i]=-99.
  H75Miss[i]=-99.
  TacMiss[i]=-99.
  psMiss[i]=-99.
  WDMiss[i]=-99.
  WSMiss[i]=-99.
  HhMiss[i]=-99.
  TahMiss[i]=-99.
 endelse
 print, i+1,FcMiss[i],FeMiss[i],FhMiss[i],FmMiss[i],C75Miss[i],H75Miss[i],TacMiss[i],$
  psMiss[i],WDMiss[i],WSMiss[i],HhMiss[i],TahMiss[i],format='(13I4)'
 printf,OutLUN, i+1,FcMiss[i],FeMiss[i],FhMiss[i],FmMiss[i],C75Miss[i],H75Miss[i],TacMiss[i],$
  psMiss[i],WDMiss[i],WSMiss[i],HhMiss[i],TahMiss[i],format='(13I4)'
endfor
FcMiss[12]=mean(FcMiss[0:11])
FeMiss[12]=mean(FeMiss[0:11])
FhMiss[12]=mean(FhMiss[0:11])
FmMiss[12]=mean(FmMiss[0:11])
C75Miss[12]=mean(C75Miss[0:11])
H75Miss[12]=mean(H75Miss[0:11])
TacMiss[12]=mean(TacMiss[0:11])
psMiss[12]=mean(psMiss[0:11])
WDMiss[12]=mean(WDMiss[0:11])
WSMiss[12]=mean(WSMiss[0:11])
HhMiss[12]=mean(HhMiss[0:11])
TahMiss[12]=mean(TahMiss[0:11])
print,'Year',FcMiss[12],FeMiss[12],FhMiss[12],FmMiss[12],C75Miss[12],H75Miss[12],TacMiss[12],$
  psMiss[12],WDMiss[12],WSMiss[12],HhMiss[12],TahMiss[12],format='(A,12I4)'
printf,OutLUN,'Year',FcMiss[12],FeMiss[12],FhMiss[12],FmMiss[12],C75Miss[12],H75Miss[12],TacMiss[12],$
  psMiss[12],WDMiss[12],WSMiss[12],HhMiss[12],TahMiss[12],format='(A,12I4)'

finish:
free_lun,OutLUN
end