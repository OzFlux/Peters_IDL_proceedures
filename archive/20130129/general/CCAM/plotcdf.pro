pro plotcdf

InName='d:\isa013\ILCCAC\Data\CC\Alb_Globe_01.nc'
ncid=ncdf_open(InName)

Var0Struct=ncdf_varinq(ncid,0)
print,'VarID 0 is ',Var0Struct.Name
Var1Struct=ncdf_varinq(ncid,1)
print,'VarID 1 is ',Var1Struct.Name
Var2Struct=ncdf_varinq(ncid,2)
print,'VarID 2 is ',Var2Struct.Name

ncdf_varget,ncid,0,Data
ncdf_varget,ncid,1,Latitude
ncdf_varget,ncid,2,Longitude

NEle = n_elements(Data)
Data = rebin(Data,NEle/2)
Latitude = rebin(Latitude,NEle/2)
Longitude = rebin(Longitude,NEle/2)

triangulate,Longitude,Latitude,Triangles
grid=griddata(Longitude,Latitude,Data,/nearest_neighbor,triangles=Triangles,dimension=[430,350])
;loadct,12
window,0,xsize=430,ysize=350
tvscl,grid

end