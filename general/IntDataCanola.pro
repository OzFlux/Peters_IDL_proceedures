PRO IntDataCanola

 GetFC,'d:\oasis95\ground\brown\past15.csv',PData
 GetSer, PData, PDay, 'Day', 0, 0, 1
 GetSer, PData, PHour, 'Hour', 0, 0, 1
 GetSer, PData, PMinute, 'Minute', 0, 0, 1
 GetSer, PData, Pp, 'p', 0, 0, 1

 GetFC,'d:\oasis95\ground\brown\cano20.csv',CData
 GetSer, CData, CDay, 'Day', 0, 0, 1
 GetSer, CData, CHour, 'Hour', 0, 0, 1
 GetSer, CData, CMinute, 'Minute', 0, 0, 1
 GetSer, CData, CTa, 'Ta', 0, 0, 1
 GetSer, CData, CWS, 'WS', 0, 0, 1
 GetSer, CData, CWD, 'WD', 0, 0, 1
 GetSer, CData, CSin, 'Sin', 0, 0, 1
 GetSer, CData, CRn, 'Rn', 0, 0, 1
 GetSer, CData, CG, 'G', 0, 0, 1
 GetSer, CData, CH, 'H', 0, 0, 1
 GetSer, CData, CE, 'E', 0, 0, 1
 GetSer, CData, CUs, 'ustar', 0, 0, 1

 PTime = DOUBLE(PDay + (PHour + PMinute/60.)/24.)
 CTime = DOUBLE(CDay + (CHour + CMinute/60.)/24.)

 Cp   = LinInt(Pp, PTime, CTime)

 Header = 'DDD,HH,MM,hPa,C,m/s,deg,W/m^2,W/m^2,W/m^2,W/m^2,W/m^2,m/s'
 PutSer, OData, CDay, 'Day'
 PutSer, OData, CHour, 'Hour'
 PutSer, OData, CMinute, 'Minute'
 PutSer, OData, Cp, 'p'
 PutSer, OData, CTa, 'Ta'
 PutSer, OData, CWS, 'WS'
 PutSer, OData, CWD, 'WD'
 PutSer, OData, CSin, 'Sin'
 PutSer, OData, CRn, 'Rn'
 PutSer, OData, CG, 'G'
 PutSer, OData, CH, 'H'
 PutSer, OData, CE, 'E'
 PutSer, OData, CUs, 'ustar'
 PutCSV, 'd:\oasis95\ground\brown\cano20p.csv', OData, Header, '(3I8,3F8.1,6I8,F9.2)'

END
