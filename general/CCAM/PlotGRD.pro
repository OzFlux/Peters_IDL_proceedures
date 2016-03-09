PRO PlotGRD

  GRDFileName = DIALOG_PICKFILE(TITLE='Select grid file', FILTER='*.grd')

  ReadGrd, GRDFileName, MetaData, Data
  PRINT, MetaData

  Index = WHERE(Data EQ 1.70141E38, Count)
  IF Count NE 0 THEN Data[Index] = 0.0

  WINDOW, 0, XSIZE=860,YSIZE=700
  TVSCL, Data, ORDER=1

END