; Definitions file for output to a CGM file
PRO cgm, FileName

 COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

 SET_PLOT, 'CGM'

 IF N_ELEMENTS(FileName) GT 0 THEN BEGIN
  DEVICE, FileName = FileName
  PRINT, 'Graphics device is CGM file ', FileName
 ENDIF ELSE BEGIN
 DEVICE, FileName = 'c:\progra~1\idl52\idl.cgm'
 PRINT, 'Graphics device is CGM file c:\progra~1\idl52\idl.cgm'
 ENDELSE

 loadct, 12

 black	 = 0
 forgnd  = 0
 red	 = 163
 green   = 15
 yellow	 = 30
 blue	 = 89
 magenta = 118
 cyan	 = 74
 white	 = 222
 iwhite	 = 255

END
