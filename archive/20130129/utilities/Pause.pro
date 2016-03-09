PRO Pause,Message

   NEle = N_ELEMENTS(Message)
   CASE 1 OF
    (NEle EQ 0) : BEGIN
     Text = MAKE_ARRAY(1,/STRING)
     Text[0] = 'Do you want to continue ?'
     END
    ELSE: BEGIN
     Text = MAKE_ARRAY(2,/STRING)
     Text[0] = CleanString(Message)
     Text[1] = 'Do you want to continue ?'
     END
   ENDCASE
   Result = DIALOG_MESSAGE(Text,/QUESTION)
   IF Result EQ 'No' THEN BEGIN
    PRINT, 'Program halted at Pause'
    RETALL
   ENDIF

END