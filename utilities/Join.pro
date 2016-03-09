PRO Join, Out, In1, In2

 IF N_ELEMENTS(In2) EQ 0 THEN BEGIN
  Out = In1
 ENDIF ELSE BEGIN
  Out = [In1,In2]
 ENDELSE

END
