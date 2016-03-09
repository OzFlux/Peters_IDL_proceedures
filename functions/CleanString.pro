FUNCTION CleanString, Line
; Function to clean up lines read from files.
; This function removes leading and trailing spaces, removes extraneous
; white space and removes any text that occurs after a semi-colon character.
 Line = STRTRIM(STRCOMPRESS(Line),2)			; Remove leading and trailing spaces
 Psn = STRPOS(Line,';')							; Position of first semi-colon
 IF Psn NE -1 THEN Line = STRMID(Line,0,Psn)	; String up to first semi-colon
 RETURN, Line
END
