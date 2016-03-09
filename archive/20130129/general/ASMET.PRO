pro asmet, InFileName, CmdDevice

; Routine to plot a combination of met data as an altitude series.

; Save any system variables that may be changed
    OldPMulti = !P.MULTI
    OldPPsn   = !P.POSITION

; Declare the ReadB1 common block
    COMMON Raw_Data, NSer, NRec, SerLab, TimeTag, Data
; Declare the graphics device colour definitions common block
    COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite
; Declare and initialise variables
    First = 418
    Last  = 1165

; Set up the graphics device
    IF (N_ELEMENTS(CmdDevice) EQ 0) THEN BEGIN
     Device = 'vga'	; Default graphics device is the screen
     OutDev, /close	; Close open files and windows, reset to VGA
     WAIT, 0.1		; Give WfWG time to clean up the screen
    ENDIF ELSE BEGIN
     Device = CmdDevice
    ENDELSE

; Get the input file name
    IF (N_ELEMENTS(InFileName) EQ 0) THEN InFileName = pickfile(Title='Select a met file')

; Read the input file, ReadB1 returns the number of series (NSer), the number of
; records in the series (NRec), the series labels (SerLab), the time tag (TimeTag)
; and the data (Data) in the common block Raw_Data.
    ReadB1, InFileName

; Get the required series
    GetSer, ps,   'ps'  , First, Last,1
    GetSer, zPS,  'zPS' , First, Last,1
    GetSer, tas,  'tas' , First, Last,1
    GetSer, ias,  'ias' , First, Last,1
    GetSer, alfa, 'alfa', First, Last,1
    GetSer, beta, 'beta', First, Last,1
    GetSer, taML, 'taML', First, Last,1
    GetSer, thML, 'thML', First, Last,1
    GetSer, taRF, 'taRF', First, Last,1
    GetSer, thRF, 'thRF', First, Last,1
    GetSer, qML,  'qML' , First, Last,1
    GetSer, qLY,  'qLY' , First, Last,1
    NumPts = N_ELEMENTS(ps)

plotem:
; Make the title
    TitleStr = 'Met data'	; Plot title
; Set up the output device
    OutDev, Device=Device, Title=TitleStr, Name=OutFile

; Set the overall character size
    !P.CHARSIZE = 1.75
; Get the maximum height
    MaxHt = MAX(zPS)

; Plot the data
; Reverse flow and MeteoLab thermocouple potential temperatures
    InitPlot, Plot1, NumPts, 2
    Plot1.X(0,*)    = thRF
    Plot1.Legend(0) = 'thRF (red)'
    Plot1.XColor(0) = red
    Plot1.X(1,*)    = thML
    Plot1.Legend(1) = 'thML (blue)'
    Plot1.XColor(1) = blue
    Plot1.Y         = zPS
    Plot1.XTitle    = 'PotlTemp (K)'
    Plot1.YTitle    = 'Pressure Altitude (m) '+InFileName
; Humidities from the Lyman Alpha and dew-point mirror
    InitPlot, Plot2, NumPts, 2
    Plot2.X(0,*)    = qML
    Plot2.Legend(0) = 'qML (blue)'
    Plot2.XColor(0) = blue
    Plot2.X(1,*)    = qLY
    Plot2.Legend(1) = 'qLY (green)'
    Plot2.XColor(1) = green
    Plot2.Y         = zPS
    Plot2.XTitle    = 'Humidity (g/kg)'
    Plot2.YCharSize = 0.01
; Angle of attack (alpha) and side slip (beta)
    InitPlot, Plot3, NumPts, 2
    Plot3.X(0,*)    = alfa
    Plot3.Legend(0) = 'A (green)'
    Plot3.XColor(0) = green
    Plot3.X(1,*)    = beta
    Plot3.Legend(1) = 'B (yellow)'
    Plot3.XColor(1) = yellow
    Plot3.Y         = zPS
    Plot3.XTitle    = 'Alpha/Beta (deg)'
    Plot3.YCharSize = 0.01
; Reverse flow and MeteoLab thermocouple temperatures
    InitPlot, Plot4, NumPts, 2
    Plot4.X(0,*)    = taRF
    Plot4.Legend(0) = 'taML (red)'
    Plot4.XColor(0) = red
    Plot4.X(1,*)    = taML
    Plot4.Legend(1) = 'taML (blue)'
    Plot4.XColor(1) = blue
    Plot4.Y         = zPS
    Plot4.XTitle    = 'Temp (degC)'
    Plot4.YCharSize = 0.01
; True and indictated air speed
    InitPlot, Plot5, NumPts, 2
    Plot5.X(0,*)    = tas
    Plot5.Legend(0) = 'tas (magenta)'
    Plot5.XColor(0) = magenta
    Plot5.X(1,*)    = ias
    Plot5.Legend(1) = 'ias (green)'
    Plot5.XColor(1) = green
    Plot5.Y         = zPS
    Plot5.XTitle    = 'AirSpeed (m/s)'
    Plot5.YCharSize = 0.01
; Static pressure
    InitPlot, Plot6, NumPts
    Plot6.X         = ps
    Plot6.Legend    = 'ps (white)'
    Plot6.XColor    = white
    Plot6.Y         = zPS
    Plot6.XTitle    = 'Pressure (hPa)'
    Plot6.YCharSize = 0.01

    XYPlot, Plot1, Plot2, Plot3, Plot4, Plot5, Plot6

; Put the "print/continue/quit" buttons on the screen
    IF (STRLOWCASE(Device) EQ 'vga') THEN BEGIN		; Screen is current graphics device
     UsrVal = PrtBtn()					; Put up the print widget
     IF (STRLOWCASE(UsrVal) EQ 'quit')     THEN GOTO, finish	; 'Quit' was selected
     IF (STRLOWCASE(UsrVal) EQ 'continue') THEN BEGIN		; 'Continue' was selected
      OutDev, /close
      Device = 'vga'					; Reset the graphics device to the screen
      GOTO, finish
     ENDIF
     Device = UsrVal					; User selected graphics device
     GOTO, plotem					; Repeat plot
    ENDIF ELSE BEGIN					; Screen not current graphics device
     OutDev, Device=Device, OutFile=OutFile, /close	; Close file and print if required
     Device = 'vga'					; Reset the graphics device to the screen
    ENDELSE

finish:
; Reset the system variables to one plot per page
    !P.MULTI    = OldPMulti
    !P.POSITION = OldPPsn

end
