HEADER
; IDL Visual Widget Builder Resource file. Version 1
; Generated on:	01/17/102 20:48.15
VERSION 1
END

TwoButtons BASE 0 0 193 102
KILLNOTIFY "OK"
TLB
CAPTION "Choose One"
XPAD = 3
YPAD = 3
SPACE = 3
BEGIN
  OK_Button PUSHBUTTON 23 24 0 0
  VALUE "OK"
  ALIGNCENTER
  ONACTIVATE "OK"
  END
  Cancel_Button PUSHBUTTON 99 25 0 0
  VALUE "Cancel"
  ALIGNCENTER
  ONACTIVATE "Cancel"
  END
END
