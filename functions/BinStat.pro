function BinStat, Ser1, Ser2, Upper, Lower, Step

; Bin Ser1 according to the value of elements in Ser2 and get the mean,
; standard deviation, maximum, minimum and count of the Ser1 bins.
;
; Upper, Lower can be calculated as in the following example (a value of
; 1.0 has been assumed for the step between bins).
; Step = 1.
; Mn = min(Ser2)
; Mx = max(Ser2)
; Lower = (fix(Mn/Step)+0.5)*Step - (Step/2.)
; Upper = (fix(Mx/Step)+0.5)*Step + (Step/2.)

  if n_elements(Ser1) ne n_elements(Ser2) then begin
   print, 'Number of elements in the input series does not match'
   return,0
  endif

  Tmp1 = Ser1
  Tmp2 = Ser2[where(Ser2 GE Lower and Ser2 LE Upper)]
  NExc = n_elements(Ser2) - n_elements(Tmp2)
  if NExc ne 0 then print, NExc, ' elements of conditional series outside range'
  NOut = fix((Upper-Lower)/Step)

  Bin = {Mid:fltarr(NOut),Avg:fltarr(NOut),Std:fltarr(NOut),Max:fltarr(NOut), $
             Min:fltarr(NOut),Num:intarr(NOut)}

  Index = fix((Tmp2-Lower)/Step)

  for i = 0, NOut-1 do begin
   Bin.Mid[i] = float(i)*Step + Lower + Step/2.
   Ind = where(Index eq i, Count)
   if Count ne 0 then begin
    if n_elements(Tmp1[Ind]) ge 2 then begin
     Bin.Avg[i] = mean(Tmp1[Ind])
     Bin.Std[i] = stddev(Tmp1[Ind])
     Bin.Max[i] = max(Tmp1[Ind])
     Bin.Min[i] = min(Tmp1[Ind])
     Bin.Num[i] = n_elements(Tmp1[Ind])
    endif
    if n_elements(Tmp1[Ind]) eq 1 then begin
     Bin.Avg[i] = Tmp1[Ind]
     Bin.Std[i] = 0.0
     Bin.Max[i] = Tmp1[Ind]
     Bin.Min[i] = Tmp1[Ind]
     Bin.Num[i] = 1
    endif
    if n_elements(Tmp1[Ind]) eq 0 then begin
     print, 'BinStat: This should never happen !'
    endif
   endif else begin
    Bin.Avg[i] = -9999.
    Bin.Std[i] = -9999.
    Bin.Max[i] = -9999.
    Bin.Min[i] = -9999.
    Bin.Num[i] = 0
   endelse
  endfor

  return,Bin

end

