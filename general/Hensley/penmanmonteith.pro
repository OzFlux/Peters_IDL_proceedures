function PenmanMonteith,metdata,measurementheight,roughnesslength

 Hour = metdata.Hour
 Fsd = metdata.Fsd
 Fe_PM = make_array(n_elements(Hour),/float,value=-9999)
 Index = where(Fsd ge 10,count)
 if count eq 0 then stop,'PenmanMonteith: No good Fsd data'
; Your code goes here
 Fe_PM[Index] = float(Hour[Index]*0)

end
