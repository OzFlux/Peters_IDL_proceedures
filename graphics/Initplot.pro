
pro InitPlot, P

; AUTHOR	: PRI
; DATE		: 09/07/01
; PROJECT	: RAMF
; DESCRIPTION	:
; ARGUMENTS PASSED :
; ARGUMENTS RETURNED
;  P		- the plot data structure
; PLOT DATA STRUCTURE

; Declare the graphics device colour definitions common block
    COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

    P = {Num:0,XOrg:0.0,YOrg:0.0,XLen:0.0,YLen:0.0}

end
