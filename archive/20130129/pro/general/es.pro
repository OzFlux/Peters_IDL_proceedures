function es, Ta
; Returns the saturation vapour pressure at a specified temperature
;  es in hPa
;  Ta in C
 return,6.106*exp(17.27*Ta/(Ta+237.3))
end