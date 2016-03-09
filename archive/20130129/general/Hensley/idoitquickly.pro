pro idoitquickly

;PURPOSE
; To demonstrate some IDL programming concepts by reading data from
; an ASCII file, loading it into a structure and passing that
; data structure to another function that does something with the
; data.
;INPUTS
;OUTPUTS
;METHOD
;USES
;AUTHOR:
; Peter Isaac
;DATE:
; 13/03/2009
;MODIFICATIONS:
;TODO:

 metfilename = "test.txt"
 metdata = readmet(metfilename)

 Fe_PM = PenmanMonteith(metdata,z,z0)

end