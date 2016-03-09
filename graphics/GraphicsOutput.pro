FUNCTION GraphicsOutput

 COMMON GO, GO_Result

Tmp = !D.NAME
 CASE Tmp OF
  'WIN': SelectGraphicsOutput
  'CGM': BEGIN
    DEVICE,/CLOSE_FILE
    SET_PLOT,'WIN'
    GO_Result = 0
    END
  'PRINTER': BEGIN
    DEVICE,/CLOSE_DOCUMENT
    SET_PLOT,'WIN'
    GO_Result = 0
    END
 ENDCASE
 RETURN, GO_Result

END