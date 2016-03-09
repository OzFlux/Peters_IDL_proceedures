
pro XYPlot, P1, P2, P3, P4, P5, P6, P7, P8, P9, PA

; Set the number of plots on this page and the sizing and positioning
; data.  This is used in the !P.POSITION graphics sysvar when the series
; are plotted.
    NumPlt = 0
    IF (N_ELEMENTS(P1) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P2) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P3) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P4) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P5) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P6) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P7) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P8) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(P9) NE 0) THEN NumPlt = NumPlt + 1
    IF (N_ELEMENTS(PA) NE 0) THEN NumPlt = NumPlt + 1
    PWd   = 0.9/NumPlt
    XOrg  = 0.08
    YOrg  = 0.08
    PHt   = 0.9
; Panel plots vertically on the page
    !P.MULTI = [0,NumPlt,0,0,0]  

; Do the plots
    IF (N_ELEMENTS(P1) NE 0) THEN VPlot, 1, P1, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P2) NE 0) THEN VPlot, 2, P2, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P3) NE 0) THEN VPlot, 3, P3, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P4) NE 0) THEN VPlot, 4, P4, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P5) NE 0) THEN VPlot, 5, P5, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P6) NE 0) THEN VPlot, 6, P6, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P7) NE 0) THEN VPlot, 7, P7, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P8) NE 0) THEN VPlot, 8, P8, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(P9) NE 0) THEN VPlot, 9, P9, XOrg, YOrg, PWd, PHt
    IF (N_ELEMENTS(PA) NE 0) THEN VPlot, 10, PA, XOrg, YOrg, PWd, PHt


end
