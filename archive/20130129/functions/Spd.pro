function Spd, u, v

    if n_elements(u) ne n_elements(v) then begin
     print, 'Spd: Input series are different lengths'
     stop
    endif

    return, sqrt(u*u+v*v)

end