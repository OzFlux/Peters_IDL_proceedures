PRO IntDataWheat

 GetFC,'d:\oasis95\ground\brown\past15.csv',PData
 GetSer, PData, PDay, 'Day', 0, 0, 1
 GetSer, PData, PHour, 'Hour', 0, 0, 1
 GetSer, PData, PMinute, 'Minute', 0, 0, 1
 GetSer, PData, Pp, 'p', 0, 0, 1
 GetSer, PData, PWS, 'WS', 0, 0, 1
 GetSer, PData, PWD, 'WD', 0, 0, 1
 GetSer, PData, PSin, 'Sin', 0, 0, 1

 GetFC,'d:\oasis95\ground\wattles\whea30.csv',WData
 GetSer, WData, WDay, 'Day', 0, 0, 1
 GetSer, WData, WHour, 'Hour', 0, 0, 1
 GetSer, WData, WMinute, 'Minute', 0, 0, 1
 GetSer, WData, WTa, 'Ta', 0, 0, 1
 GetSer, WData, WWS, 'WS', 0, 0, 1
 GetSer, WData, WRn, 'Rn', 0, 0, 1
 GetSer, WData, WG, 'G', 0, 0, 1
 GetSer, WData, WH, 'H', 0, 0, 1
 GetSer, WData, WE, 'E', 0, 0, 1
 GetSer, WData, WUs, 'ustar', 0, 0, 1

 PTime = DOUBLE(PDay + (PHour + PMinute/60.)/24.)
 WTime = DOUBLE(WDay + (WHour + WMinute/60.)/24.)

 UV = UVFromGSTrk(PWS, PWD)
 PU = UV[0,*]
 PV = UV[1,*]

 Wp   = LinInt(Pp, PTime, WTime)
 WSin = LinInt(PSin, PTime, WTime)
 WU   = LinInt(PU, PTime, WTime)
 WV   = LinInt(PV, PTime, WTime)

 GSTrk = GSTrkFromUV(WU, WV)
 WWD = GSTrk[1,*]

 Header = 'DDD,HH,MM,hPa,C,m/s,deg,W/m^2,W/m^2,W/m^2,W/m^2,W/m^2,m/s'
 PutSer, OData, WDay, 'Day'
 PutSer, OData, WHour, 'Hour'
 PutSer, OData, WMinute, 'Minute'
 PutSer, OData, Wp, 'p'
 PutSer, OData, WTa, 'Ta'
 PutSer, OData, WWS, 'WS'
 PutSer, OData, WWD, 'WD'
 PutSer, OData, WSin, 'Sin'
 PutSer, OData, WRn, 'Rn'
 PutSer, OData, WG, 'G'
 PutSer, OData, WH, 'H'
 PutSer, OData, WE, 'E'
 PutSer, OData, WUs, 'ustar'
 PutCSV, 'd:\oasis95\ground\wattles\whea30p.csv', OData, Header, '(3I8,3F8.1,6I8,F9.2)'

END
