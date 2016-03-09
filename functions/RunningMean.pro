function RunningMean, InSer, Avg, Jump

; Generate a running mean series.  InSer will be averaged over boxes
; Avg elements wide spaced Jump elements apart.

    NEle = n_elements(InSer)
    NSeg = fix(NEle/Jump)
    RunMean = fltarr(NSeg)
    Ind = indgen(Avg)
    for i = 0, NSeg-1 do begin
     Index = Ind + i*Jump
     RunMean(i) = mean(InSer(Index))
    endfor
    return, RunMean

end
