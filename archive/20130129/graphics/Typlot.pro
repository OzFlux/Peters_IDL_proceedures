
pro TYPlot, G0, G1, G2, G3, G4, G5, G6, G7, G8, G9

 common Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

; Set the number of graphs on this page and the sizing and positioning
; data.  This is used in the !P.POSITION graphics sysvar when the series
; are plotted.
 NGraph = n_params()

 XOrg = 0.08
 YOrg = 0.08
 XLen = 0.9
 YLen = 0.9/NGraph

; Panel plots vertically on the page
 !P.MULTI = [0,1,NGraph,0,0]

; Do the plots
 for i = 0, NGraph-1 do begin
  if (i eq 0) then G = G0
  if (i eq 1) then G = G1
  if (i eq 2) then G = G2
  if (i eq 3) then G = G3
  if (i eq 4) then G = G4
  if (i eq 5) then G = G5
  if (i eq 6) then G = G6
  if (i eq 7) then G = G7
  if (i eq 8) then G = G8
  if (i eq 9) then G = G9
  BLX = XOrg+G.LMargin
  BLY = YOrg+i*YLen+G.BMargin
  TRX = XOrg+XLen-G.RMargin
  TRY = YOrg+(i+1)*YLen-G.TMargin
  !P.POSITION=[BLX,BLY,TRX,TRY]	; Set the sysvar controlling plot position

  if (G.XRange(0) eq 0.0) and (G.XRange(1) eq 0.0) then G.XRange = [min(G.X), max(G.X)]
  if (G.YRange(0) eq 0.0) and (G.YRange(1) eq 0.0) then G.YRange = [min(G.Y), max(G.Y)]

  plot, G.X, G.Y, /nodata, $
   xtitle=G.XTitle,xrange=G.XRange,xcharsize=G.XCharSize, $
   xstyle=G.XStyle,ystyle=G.YStyle,ycharsize=G.YCharSize, $
   ytitle=G.YTitle,yrange=G.YRange, $
   color=forgnd

  GXSize = size(G.X)
  NXSer = GXSize(1)
  for j = 0, NXSer-1 do begin
   oplot, G.X(j,*), G.Y(*), color=G.XColor(j)
   xyouts, BLX+0.02, BLY+(j+1)*0.02, G.Legend(j), color=G.XColor(j), /normal
  endfor

 endfor

end
