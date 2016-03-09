PRO PrtBtn_Event, event

; Event handler for the PrtBtn function.  The event manager passes control
; to this code when a mouse click is received.

  COMMON PrtBtn, UsrVal
  UsrVal = ' '

; Get the user choice and put it into UsrVal
  WIDGET_CONTROL, event.id, GET_UVALUE = UsrVal
; Remove the widget
  WIDGET_CONTROL, event.top, /DESTROY
; Return to the event manager call in the routine that produced the widget
END

FUNCTION PrtBtn, GROUP = GROUP

; Widget FUNCTION to put a widget on the screen containing three buttons.
; The buttons are 'Print', 'Continue' and 'Quit'.
; 1) 'Print'
;	- when pushed this reveals a pull down menu containing the items
;	  'File' and 'Printer'
;	  - the 'File' menu contains a sub-menu of available graphics
;	    file types, currently only HPGL, CGM and PCL are supported
;	  - the 'Printer' menu contains a sub-menu of available printers,
;	    currently only the HP LaserJet III is supported.
;	- when an item is selected, the text string of that item is
;	  returned as the result of the function
; 2) 'Continue'
;	- when pushed this returns the text string 'Continue' as the result
;	  of the function
; 3) 'Quit'
;	- when pushed this returns the text string 'Quit' as the result of
;	  the function
; The common block PrtBtn is used to pass the selected item from the
; event handler back to the function so it can be used as the return value.
; This procedure is based almost entirely on the WPDMENU.PRO demo.

  COMMON PrtBtn, UsrVal

; Set up the basic box for the buttons.
  base = WIDGET_BASE( $
          TITLE='Print Graph', $
          XSIZE=250, SPACE=25, $
          XPAD=25, YPAD=25, $
          XOFFSET=100, YOFFSET=100, $
          /ROW)

; Define the buttons and sub-menus to appear in the box
  items = ['"Print" {','"File" {','"HPGL"','"CGM"','"PCL"','}', $
                       '"Printer" {','"HP3"','}','}', $
           '"Continue"', $
           '"Quit"']

; Generate the buttons and sub-menus
  XPDMENU, items, base

; Put the widget on the screen
  WIDGET_CONTROL, base, /REALIZE

; Hand over to the event manager
  XMANAGER, 'PrtBtn', base, GROUP_LEADER = GROUP

; Return to calling routine with the selected item
RETURN, UsrVal

END
