PRO PlotFLT

  Path = 'C:\PROJECTS\CCAM\VEGETATION\NPP'
  FLTFileName = DIALOG_PICKFILE(TITLE='Select grid file', FILTER='*.flt', PATH=Path)

  ReadFLT, FLTFileName, MetaData, Data
  PRINT, MetaData

  Index = WHERE(Data NE -9999.0, Count)
  IF Count NE 0 THEN PRINT, TOTAL(Data[Index])

  Index = WHERE(Data EQ -9999.0, Count)
  IF Count NE 0 THEN Data[Index] = 0.0

  LOADCT, 12
  WINDOW, 0, XSIZE=860,YSIZE=700
  TVSCL, Data, ORDER=1

END