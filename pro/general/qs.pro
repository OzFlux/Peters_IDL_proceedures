function qs, T, p
; Returns the saturation specific humidity at a specified temperature
;  qs in kg/kg
;  T in C
;  p in hPa
 Mv=0.018
 Md=0.0287
 return,(Mv / Md) * (es(T) / p)
end