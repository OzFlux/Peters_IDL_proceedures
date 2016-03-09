FUNCTION UbCWIC, z
; PURPOSE:
; INPUT (EXPLICIT):
; INPUT (IMPLICIT):
; OUTPUT:
; AUTHOR: PRI
; DATE: 05/01/2003
 COMMON Constants
 COMMON UbCWIC
 u = (FVel/k)*(ALOG(z/RLen)-Psim(z,MOLen))
 RETURN, u*A*EXP(-(z/(b*ZbAtX))^s)/(ZbAtX*Uzb)
END