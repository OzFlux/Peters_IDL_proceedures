HEADER
; IDL Visual Widget Builder Resource file. Version 1
; Generated on:	01/19/102 16:14.27
VERSION 1
END

SelectGraphicsOutput BASE 0 0 230 85
TLB
CAPTION "Output graphics to ..."
XPAD = 3
YPAD = 3
SPACE = 3
SYSMENU = 2
BEGIN
  PBtn_CGMFile PUSHBUTTON 10 15 60 25
  VALUE "CGM File"
  FRAME = 1
  ALIGNCENTER
  ONACTIVATE "CGMFile"
  END
  PBtn_Printer PUSHBUTTON 80 15 60 25
  VALUE "Printer"
  FRAME = 1
  ALIGNCENTER
  ONACTIVATE "Printer"
  END
  PBtn_Continue PUSHBUTTON 150 15 60 25
  VALUE "None"
  FRAME = 1
  ALIGNCENTER
  ONACTIVATE "None"
  END
END
