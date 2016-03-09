FUNCTION Shape, zb, z0, L, c
; PURPOSE:
;  This function returns the value of the shape parameter.  The expressions
;  used come from Finn et al (1996).
; INPUT:
;  zb - mean plume height, m
;  z0 - roughness length, m
;  L  - Monin-Obukhov length, m
;  c  - fraction of mean plume height at which the mean wind speed
;       equals the plume advection speed
; OUTPUT:
;  s - value of the shape parameter, returned by function
; AUTHOR: PRI
; DATE: 24/12/2002
 IF (1./L GT 0.) THEN $
  s = ((1.+5.*c*zb/L)/(ALOG(c*zb/z0)-psim(c*zb,L))) + (1.+10.*c*zb/L)/(1.+5.*c*zb/L)
 IF (1./L LE 0.) THEN $
  s = (1./((ALOG(c*zb/z0)-psim(c*zb,L))*(1.-16.*c*zb/L)^0.25)) + (1.-8.*c*zb/L)/(1.-16.*c*zb/L)
 RETURN, s

END