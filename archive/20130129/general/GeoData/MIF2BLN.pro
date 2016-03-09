PRO MIF2BLN

; *** Declare some constants and variables.
  FCode = 'CONNECTOR' ;'WATERCOURS_L'
  FName = 'MURRUMBIDGEE RIVER'
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

  NMIDLines = 0
  WHILE NOT EOF(MIFLun) DO BEGIN
   READF, MIFLun, MIFLine
   StrParts = STR_SEP(MIFLine,' ',/REMOVE_ALL)
;   PRINT, NMIDLines, StrParts[0]
   CASE STRUPCASE(StrParts[0]) OF
    'PLINE': BEGIN
      READS, StrParts[1], NumPts
      READF, MIDLun, MIDLine
      NMIDLines = NMIDLines + 1
      StrParts = STR_SEP(MIDLine,',')
      Feature = STRUPCASE(StrParts[7])
      Name = STRUPCASE(StrParts[8])
;      PRINT, Feature, Name
;      PRINT, FCode, FName
      CASE 1 OF
       (Feature EQ FCode) AND (Name EQ FName): BEGIN
         PRINTF, OutLun, NumPts, 1, FORMAT='(2I5)'
         FOR i = 1, NumPts DO BEGIN
          READF, MIFLun, Longitude, Latitude
          PRINTF, OutLun, Longitude, Latitude, FORMAT='(2F10.4)'
         ENDFOR
        END
       ELSE: FOR i = 1, NumPts DO READF, MIFLun, Longitude, Latitude
      ENDCASE
     END
    'LINE': BEGIN
      READS, StrParts[1], Long1
      READS, StrParts[2], Lat1
      READS, StrParts[3], Long2
      READS, StrParts[4], Lat2
      READF, MIDLun, MIDLine
      NMIDLines = NMIDLines + 1
      StrParts = STR_SEP(MIDLine,',')
      Feature = STRUPCASE(StrParts[7])
      Name = STRUPCASE(StrParts[8])
;      PRINT, Feature, Name
;      PRINT, FCode, FName
      IF (Feature EQ FCode) AND (Name EQ FName) THEN BEGIN
       PRINTF, OutLun, 2, 1, FORMAT='(2I5)'
       PRINTF, OutLun, Long1, Lat1, FORMAT='(2F10.4)'
       PRINTF, OutLun, Long2, Lat2, FORMAT='(2F10.4)'
      ENDIF
     END
    ELSE: Pause, 'MIF2BLM: Unrecognised .MIF entry; '+MIFLine
   ENDCASE

  ENDWHILE

; *** Close files and finish.
  FREE_LUN, MIDLun
  FREE_LUN, MIFLun
  FREE_LUN, OutLun

END