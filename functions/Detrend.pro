function Detrend, In, Order

 if Order lt 1 then begin
  print, 'Detrend: requested order of fit equation less than 1'
  stop
 endif
 if Order gt 3 then begin
  print, 'Detrend: requested order of fit equation greater than 3'
  stop
 endif
 M = Order + 1

 Tmp = findgen(n_elements(In))
 A = svdfit(Tmp, In, M)
 case Order of
  1: Out = In - (A(1)*Tmp + A(0))
  2: Out = In - (A(2)*Tmp^2 + A(1)*Tmp +A(0))
  3: Out = In - (A(3)*Tmp^3 + A(2)*Tmp^2 + A(1)*Tmp + A(0))
 endcase

 return, Out

end