
pro InitGraph, G, NRec, NXSer

; AUTHOR	: PRI
; DATE		: 21/07/96
; PROJECT	: RAMF
; DESCRIPTION	:
;  This procedure defines the data structure used to pass information to the
;  plotting routines XYPLOT, VPLOT and HPLOT.  It must be called before any
;  calls to these routines.
;
;  Information on what data to graph (eg the X and Y series) and how to graph
;  it (eg the colour, character sizes etc) are passed to the graphing
;  routines via the structure defined by this routine.  This routine also
;  sets some of the structure fields to default values so that not all fields
;  need to be set in the calling routine.
;
;  The general method of use is :
;   - call this procedure (InitGraph) to define the plot data structure
;   - set the required fields (eg X and Y data series) in the calling routine
;   - call the XYPLOT Routine to plot the data
; ARGUMENTS PASSED :
;  G		- the name of the structure to be defined, STRUCTURE
;  NRec		- the number of records in the data series to be plotted, INTEGER
;  NXSer	- the number of data series to be plotted on the same X axis, INTEGER
; ARGUMENTS RETURNED
;  G		- the plot data structure
; GRAPH DATA STRUCTURE
;  A decsription of the plot data structure fields is given below.  Most of
;  the fields in the structure correspond to keywords used by the IDL plotting
;  routines and use the same values.
;  X		- the array of data series to be plotted as the X value, this array
;		  is dimensioned (NXSer,NRec).  When only one series is to be plotted
;		  this array has only one dimension, when two series are to be plotted
;		  on the same graph, this array has two dimensions, one to contain each
;		  series to be plotted. (TYPE FLOATING POINT ARRAY)
;  Y		- the array of data series to be plotted as the Y value, this array
;		  is dimensioned (NRec).  As at 21/07/96, only one Y series is allowed.
;		  (TYPE FLOATING POINT ARRAY)
;  XRange	- a two element floating point array containing the minimum and
;         maximum values of the X axis.  The default values are 0.0.  If
;         unchanged by the calling routine, the plotting routine VPLOT detects
;         these default values and sets the X axis range to the data minimum
;         and maximum values.
;  YRange	- a two element floating point array containing the minimum and
;         maximum values of the Y axis.  The default values are 0.0.  If
;         unchanged by the calling routine, the plotting routine VPLOT detects
;         these default values and sets the Y axis range to the data minimum
;         and maximum values.
;  XStyle	- an integer specifying the style of X axis to be used, the values
;		  correspond to the IDL definitions used in the XSTYLE keyword for the
;		  IDL plotting routines (eg PLOT etc).
;  YStyle	- an integer specifying the style of Y axis to be used, the values
;		  correspond to the IDL definitions used in the YSTYLE keyword for the
;		  IDL plotting routines (eg PLOT etc).
;  XTitle	- a string containing the title to be used on the X axis.
;  YTitle	- a string containing the title to be used on the Y axis.
;  Title	- a string containing the title for the whole plot (not implemented
;         yet)
;  XCharSize	- an integer used to scale the currently defined character size
;         for the X axis.  This field works in the same way as the IDL plotting
;         routine keyword XCHARSIZE.
;  YCharSize	- an integer used to scale the currently defined character size
;         for the Y axis.  This field works in the same way as the IDL plotting
;         routine keyword YCHARSIZE.
;  ZCharSize	- an integer used to scale the currently defined character size
;         for the Z axis.  This field works in the same way as the IDL plotting
;         routine keyword ZCHARSIZE.
;  XColor	- an integer array of dimension NXSer used to define the colour of
;         the corresponding X data series.
;  Legend	- an string array of dimension NXSer containing the legend for the
;		  corresponding X data series.  This is plotted in the same colour as
;		  used for the corresponding X data series.
; MODS TO BE DONE :
;  1) generalise the routines involved to allow plotting of more than one Y data
;     series on the same plot.

; Declare the graphics device colour definitions common block
    COMMON Colours, black,red,green,yellow,blue,magenta,cyan,white,iwhite,forgnd

    IF (N_ELEMENTS(NXSer) LE 0) THEN NXSer = 1

    G = {X:FLTARR(NXSer, NRec), Y:FLTARR(NRec), $
         XRange:[0.0,0.0], YRange:[0.0,0.0], $
         XStyle:0, YStyle:0, $
         XTitle:' ', YTitle:' ', Title:' ', $
         XCharSize:1.0,YCharSize:1.0,ZCharSize:1.0, $
         XColor:INTARR(NXSer), Legend:STRARR(NXSer), $
         LMargin:0.0,RMargin:0.0,TMargin:0.0,BMargin:0.0}

    G.XColor = forgnd

end
