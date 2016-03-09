pro colours, Device, ColourTable

; A useful little procedure to plot 256 numbers to the current
; graphics device using the current colour table.  You can then
; read off the number of the various colours.  As an example :
; For the  Rainbow colour table (13)
;
;           HPGL VGA
; Black   = 1    1
; Red     = 2    222-256
; Green   = 3    130-170
; Yellow  = 4    186-189
; Blue    = 5    50-60
; Magenta = 6    ?
; Cyan    = 7    100-105
; Orange  = ?    200-208
;
; For the 16 level colour table (12)
;                VGA   HPGL
; Black          1     1
; Dark grey      2
; Dark green     15
; Bright green   30    3
; Blue/green     59
; Cyan           74    7
; Blue           89    5
; Magenta        118   6
; Pink           148
; Red            163   2
; Grey           192
; White          207
; Intense white  222
; Yellow         X     4

  !P.FONT = 0

  IF (N_ELEMENTS(Device) EQ 0) THEN Device = 'VGA'
  IF (STRLOWCASE(Device) EQ 'vga') THEN BEGIN
   SET_PLOT, 'win'
   WINDOW, 0, xsize=800, ysize=600
   DEVICE, set_font="arial*bold*20"
  ENDIF
  IF (STRLOWCASE(Device) EQ 'hpgl') THEN BEGIN
   SET_PLOT, 'hp'
   DEVICE, filename='c:\progra~1\idl52\general\graphics\colours.hgl'
  ENDIF
  IF (STRLOWCASE(Device) EQ 'cgm') THEN BEGIN
   SET_PLOT, 'cgm'
   DEVICE, filename='c:\progra~1\idl52\general\graphics\colours.cgm'
  ENDIF

  IF N_ELEMENTS(ColourTable) EQ 0 THEN ColourTable=12
  loadct, ColourTable

 c = -1
 for j = 15, 0, -1 do begin
  for i = 0, 15, 1 do begin
   c = c + 1
   x = 0.8*(i/15.) + 0.05
   y = 0.8*(j/15.) + 0.1
   xyouts, x, y, c, color=c, /normal
  endfor
 endfor

 IF STRLOWCASE(!D.NAME) NE 'win' THEN BEGIN
  DEVICE, /close
  SET_PLOT, 'win'
 ENDIF

end
