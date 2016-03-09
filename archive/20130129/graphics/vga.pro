; Definitions file for output to a VGA screen
pro vga
 COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

 ;SET_PLOT,'WIN'
 ;PRINT, 'Graphics device is VGA screen'

 loadct, 12

 black	 = 1	; Define the colours
 red	 = 163
 green   = 15
 yellow	 = 30
 blue	 = 89
 magenta = 118
 cyan	 = 74
 white	 = 207
 iwhite	 = 255
 forgnd  = 255

end
