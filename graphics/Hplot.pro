
pro HPlot, P, G

; AUTHOR	: PRI
; DATE		: 08/07/01
; PROJECT	: RAMF
; DESCRIPTION	:
;  This procedure plots the data series contained in the plotting data structure P
;  according to the definitions contained in the same structure, at a position
;  specified by the number of the plot (PlotNum), the origin of the graph (XOrg,YOrg)
;  and the plot width (PWd) and height (PHt).  Each graph is plotted in a new
;  row starting from the bottom and progressing up the page.
;
;  First, the routine determines how many X data series are to be plotted on the X axis,
;  defined in the plot structure P, by checking the dimensioning of the field containing
;  the X data.  For only one X data series to be plotted, this field (P.X) has only one
;  dimension, the number of records in the series to be plotted.  For two X data series,
;  the P.X field has two dimensions, each of the number of records in the series to be
;  plotted, with the first containing the data of the first series to be plotted, the
;  second containing the data of the second series to be plotted.
;
;  Next, the routine works out the bottom left X and Y coords (BLX,BLY) and the top
;  right X and Y coords (TRX,TRY) of this graph based on the orgin of the whole
;  plot (Xorg,YOrg), the number of this graph on the page (PlotNum) and the plot
;  width (PWd) and height (PHt).  These values are passed into this routine by the
;  calling routine.  The bottom left and top right X and Y coords are then used to
;  set the system variable !P.POSITION that controls where this graph will be
;  drawn on the current page.
;
;  The routine then checks to see if the ranges for the X and Y axes have been set
;  by the calling routine.  If not (indicated by the XRange and YRange fields being
;  set to 0.0), the ranges are set to the minimum and maximum of the corresponding
;  data series.
;
;  Finally, the routine draws the graph using the definitions contained in the plot
;  structure P (see routine INITPLOT for a description of these).  The axes are set
;  up using a call to the IDL routine PLOT using the /NODATA keyword to prevent the
;  X data series being plotted.  The data series are then plotted using the IDL
;  routine OPLOT.  This allows the axes to be drawn in the default colour for the current
;  graphics device (eg white for output to the screen) but the series to be plotted
;  using the colour specified in the plot structure field P.XColor.  The legend for each
;  data series being plotted is drawn using the IDL routine XYOUTS using the colour
;  corresponding to the series concerned.
; ARGUMENTS PASSED :
;  P		- the plotting data structure, see the procedure INITPLOT for a
;		  description of the fields contained in this structure.
;  XOrg		- the X coord of the graph origin, defined by the calling routine.
;  YOrg		- the Y coord of the graph origin, defined by the calling routine.
;  PWd		- the width of the plot, defined by the calling routine.
;  PHt		- the height of the plot, defined by the calling routine.
; ARGUMENTS RETURNED : None
; MODS TO BE DONE :
;  1) generalise the routines involved to allow plotting of more than one Y data series
;     on each plot.
;  2) allow the space between each plot on the page to be specified, at present this
;     defaults to zero, ie the plots touch along their Y axes.
;  3) allow the position of the legend to be specified, at present this is always
;     plotted at the bottom left corner of the graph.

    COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

; Find out how many X series are to be plotted on this graph
    GXSize = SIZE(G.X)
    NXSer  = GXSize(1)

; Get the bottom left (X,Y) and the top right (X,Y) and set the !P.POSITION
; system variable.
    BLX = P.XOrg						; Bottom left X coord
    BLY = P.YOrg + (P.Num-1) * P.YLen	; Bottom left Y coord
    TRX = BLX + P.XLen					; Top right X coord
    TRY = BLY + P.YLen					; Top right Y coord
    !P.POSITION=[BLX,BLY,TRX,TRY]	; Set the sysvar controlling plot position

    IF (G.XRange(0) EQ 0.0) AND (G.XRange(1) EQ 0.0) THEN $
     G.XRange = [MIN(G.X), MAX(G.X)]
    IF (G.YRange(0) EQ 0.0) AND (G.YRange(1) EQ 0.0) THEN $
     G.YRange = [MIN(G.Y), MAX(G.Y)]

    PLOT, G.X, G.Y, /nodata, $
     xtitle=G.XTitle,xrange=G.XRange,xcharsize=G.XCharSize, $
     xstyle=G.XStyle,ystyle=G.YStyle,ycharsize=G.YCharSize, $
     ytitle=G.YTitle,yrange=G.YRange, $
     color=forgnd

    BLXS = BLX + 0.005
    BLYS = BLY + 0.02
    FOR i = 0, NXSer-1 DO BEGIN
     OPLOT, G.X(i,*), G.Y(*), color=G.XColor(i)
     BLYS = BLYS + (i * 0.02)
     XYOUTS, BLXS, BLYS, G.Legend(i), color=G.XColor(i), /normal
    ENDFOR

end
