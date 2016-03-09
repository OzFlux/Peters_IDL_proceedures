PRO ErrorHandler, ErrText, ErrNum

CASE ErrNum OF
 0: BEGIN
     PRINT, ErrText
     Result = DIALOG_MESSAGE(ErrText,/INFORMATION)
    END
 1: BEGIN
     PRINT, ErrText
     Result = DIALOG_MESSAGE(ErrText,/ERROR)
     CLOSE,/ALL
     RETALL
    END
ELSE: BEGIN
       PRINT, ErrText
       MsgText = 'Unknown error number, error text was ' + STRING(13B) + ErrText
       Result = DIALOG_MESSAGE(MsgText,/ERROR)
       CLOSE,/ALL
       RETALL
      END
ENDCASE

END
