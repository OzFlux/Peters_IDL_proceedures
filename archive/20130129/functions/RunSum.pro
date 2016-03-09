FUNCTION RunSum, In

 Result = SIZE(In)
 IF Result[0] NE 1 THEN STOP, 'RunSum: Input must be 1D array'
 Out = MAKE_ARRAY(Result[1], /FLOAT, VALUE=-9999.)
 Out[0] = In[0]
 FOR i = 1, Result[1]-1 DO BEGIN
  Out[i] = Out[i-1] + In[i]
 ENDFOR
 RETURN, Out

END