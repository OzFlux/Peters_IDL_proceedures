PRO MIF2LLZ

; *** Declare soem constants and variables.
  MIFLine = ''
  MIDLine = ''
  FilePath = ''

  MIDFile = DIALOG_PICKFILE(Title='Select a .MID file',Path='D:\MAPS',GET_PATH=FilePath)
  MIFFile = DIALOG_PICKFILE(Title='Select a .MIF file',Path=FilePath)
  OutFile = DIALOG_PICKFILE(Title='Save output file as',Path=FilePath)
  MIDLun = GETLUN()
  MIFLun = GETLUN()
  OutLun = GETLUN()
  OPENR, MIDLun, MIDFile
  OPENR, MIFLun, MIFFile
  OPENW, OutLun, OutFile

  WHILE (STRPOS(STRUPCASE(MIFLine),'DATA') EQ -1) DO READF, MIFLun, MIFLine

  WHILE NOT EOF(MIFLun) DO BEGIN
   READF, MIFLun, MIFLine
   IF STRPOS(STRUPCASE(MIFLine),'PLINE') EQ -1 THEN Pause, 'MIF2LLZ: PLINE expected but not found'
   StrParts = STR_SEP(MIFLine,' ',/REMOVE_ALL)
   READS, StrParts[1], NumPts
   READF, MIDLun, MIDLine
   StrParts = STR_SEP(MIDLine,',',/REMOVE_ALL)
   CASE STRUPCASE(StrParts[7]) OF
    'CONTOUR': BEGIN
      READS, StrParts[8], ContourElevation
      FOR i = 1, NumPts DO BEGIN
       READF, MIFLun, Longitude, Latitude
       PRINTF, OutLun, Longitude, Latitude, ContourElevation, FORMAT='(2F10.4,I5)'
      ENDFOR
     END
    ELSE: FOR i = 1, NumPts DO READF, MIFLun, Longitude, Latitude
   ENDCASE
  ENDWHILE

; *** Close files and finish.
  FREE_LUN, MIDLun
  FREE_LUN, MIFLun
  FREE_LUN, OutLun

END