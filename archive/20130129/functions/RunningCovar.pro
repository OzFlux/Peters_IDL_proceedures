function RunningCovar, In1, In2, Avg, Jump, DOpt

; Generate a running covariance series.  The covariance of In1 and In2 will
; be calculated for boxes Avg elements wide spaced Jump elements apart.

    if n_elements(In1) ne n_elements(In2) then begin
     print, 'RunningCovar: Input series are different lengths'
     stop
    endif

    NSeg = fix(n_elements(In1)/Jump)
    RunCovar = fltarr(NSeg)
    Ind = indgen(Avg)
    for i = 0, NSeg-1 do begin
     Index = Ind + i*Jump
     RunCovar(i) = mean(Detrend(In1(Index),DOpt)*Detrend(In2(Index),DOpt))
    endfor
    return, RunCovar

end
