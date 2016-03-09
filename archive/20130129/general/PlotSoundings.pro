PRO PlotSoundings

   GetFC, 'd:\anu\metdata\upperair\wagga\sound.csv', Data
   GetSer, Data, Day,    'DDDDD', 0, 0, 1
   GetSer, Data, Height, 'HGHT',  0, 0, 1
   GetSer, Data, UCmpt,  'U',     0, 0, 1
   GetSer, Data, VCmpt,  'V',     0, 0, 1

   HgtTailDev = Convert_Coord(Height,/DATA,/TO_DEVICE)
   DayTailDev = Convert_Coord(Day,/DATA,/TO_DEVICE)
   ArrLenDev = 0.1*MIN([!D.X_SIZE,!D.Y_SIZE])
   MaxCmpt = MAX([ABS(UCmpt),ABS(VCmpt)])
   HgtHeadDev = HgtTailDev - ArrLenDev*VCmpt/MaxCmpt
   DayHeadDev = DayTailDev - ArrLenDev*UCmpt/MaxCmpt
   HgtTail = Convert_Coord(HgtHeadDev,/DEVICE,/TO_DATA)
   DayTail = Convert_Coord(DayHeadDev,/DEVICE,/TO_DATA)
   PLOT, Day, Height, /NODATA, $
    XRange=[15,27], YRange=[0,6000]
   Arrow, Day, Height, DayTail, HgtDay, /DATA

END
