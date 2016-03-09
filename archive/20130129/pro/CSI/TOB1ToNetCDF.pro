pro TOB1ToNetCDF

 InFileName = 'e:\spofatte\data\adelaideriver\tob1_cr3000_ad_river_01_feb_2008_flux.dat'

 SSecs = ulong(0)
 ESecs = ulong(0)

SYear = 2008
SMonth = 1
SDay = 1
SHour = 0
SMinute = 0
SSecond = 0

;jdcnv, SYear, SMonth, SDay, SHour, SJDay
;SSecs = ulong(SJDay*double(86400.0)) + ulong(SMinute*60.0) + ulong(SSeconds)

 readtob1, InFileName, SSecs, ESecs, Header, Time, Data
 HeaderSize = size(Header)
 TimeSize = size(Time)
 DataSize = size(Data)

 jdcnv, 1990, 1, 1, 0, SJDay
 SDays = double(Time[0,0])/double(86400.0)
 JDay = SJDay + SDays + 5.787E-6
 caldat, JDay, SMonth, SDay, SYear, SHour, SMinute, SSecond
 SDateTime = string(SDay,'/',SMonth,'/',SYear,' ',SHour,':',SMinute,':',SSecond, $
                    format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
 EDays = double(Time[0,TimeSize[2]-1])/double(86400.0)
 JDay = SJDay + EDays + 5.787E-6
 caldat, JDay, EMonth, EDay, EYear, EHour, EMinute, ESecond
 EDateTime = string(EDay,'/',EMonth,'/',EYear,' ',EHour,':',EMinute,':',ESecond, $
                    format='(I2.2,A,I2.2,A,I4.4,A,I2.2,A,I2.2,A,I2.2)')
 print, 'File contains data from ', SDateTime, ' to ', EDateTime

end