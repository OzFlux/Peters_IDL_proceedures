function Drn, u, v

    if n_elements(u) ne n_elements(v) then begin
     print, 'Drn: Input series are different lengths'
     stop
    endif

    Spd = sqrt(u*u+v*v)
    Drn = Spd * 0.0
    Index = where(u ne 0.0 and v ne 0.0, count)
    if count ne 0 then Drn[Index] = acos(u[Index]/Spd[Index]) * !RADEG
    Index = where(u gt 0.0 and v gt 0.0, count)
    if count ne 0 then Drn[Index] = 270. - Drn[Index]
    Index = where(u gt 0.0 and v lt 0.0, count)
    if count ne 0 then Drn[Index] = Drn[Index] + 270.
    Index = where(u lt 0.0 and v gt 0.0, count)
    if count ne 0 then Drn[Index] = 270. - Drn[Index]
    Index = where(u lt 0.0 and v lt 0.0, count)
    if count ne 0 then Drn[Index] = Drn[Index] - 90.
   return, Drn
end