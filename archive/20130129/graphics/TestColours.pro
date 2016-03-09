pro test, CmdDevice

; Save any system variables that may be changed
 OldPMulti = !P.MULTI
 OldPPsn   = !P.POSITION

 COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

 IF (N_ELEMENTS(CmdDevice) EQ 0) THEN BEGIN
  Device = 'vga'	; Default graphics device is the screen
  OutDev, /close	; Close open files and windows, reset to VGA
  WAIT, 0.1		; Give WfWG time to clean up the screen
 ENDIF ELSE BEGIN
  Device = CmdDevice
 ENDELSE

 x = findgen(1000)
 y = sin(x*2*!pi/100.)

plot:
; Make the title
 TitleStr = 'Met data'
; Set up the output device
 OutDev, Device=Device, Title=TitleStr, Name=OutFile

 InitGraph, G1, 1000, 1
 G1.X = x
 G1.Y = y
 G1.Legend(0) = 'SIN(X)'
 G1.TMargin = 0.01
 InitGraph, G2, 1000, 1
 G2.X = x
 G2.Y = y
 G2.Legend(0) = 'SIN(X)'
 G2.TMargin = 0.01
 InitGraph, G3, 1000, 1
 G3.X = x
 G3.Y = y
 G3.Legend(0) = 'SIN(X)'
 G3.TMargin = 0.01
 InitGraph, G4, 1000, 1
 G4.X = x
 G4.Y = y
 G4.Legend(0) = 'SIN(X)'
 G4.TMargin = 0.01

 typlot, G1, G2, G3, G4

 if (strlowcase(Device) eq 'vga') then begin	; Screen is current graphics device
  UsrVal = PrtBtn()								; Put up the print widget
  if (strlowcase(UsrVal) eq 'quit') then goto, finish	; 'Quit' was selected
  if (strlowcase(UsrVal) eq 'continue') then begin		; 'Continue' was selected
   OutDev, /close
   Device = 'vga'					; Reset the graphics device to the screen
   goto, finish
  endif
  Device = UsrVal					; User selected graphics device
  goto, plot						; Repeat plot
 endif else begin					; Screen not current graphics device
  OutDev, Device=Device, OutFile=OutFile, /close	; Close file and print if required
  Device = 'vga'					; Reset the graphics device to the screen
 endelse

finish:
 !P.MULTI = OldPMulti
 !P.POSITION = OldPPsn

end