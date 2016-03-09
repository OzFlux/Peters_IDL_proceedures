FUNCTION NumLines, LUnit

; "A mere bagatelle, a nothing, a flipancy..."
; Actually, this may be the smartest IDL procedure I have written.
; The idea is to find the number of lines in a formatted ASCII file in
; the quickest way.  This is the first attempt.  See the code for how
; it works.
; INPUTS
;  LUnit	- the logical unit of the file
; OUTPUTS
;  NumRecs	- the number of lines
;  FileSize	- the size of the file in bytes

 Stats = FSTAT(LUnit)			; Get the statistics of the file
 FileSize = Stats.Size			; Save the file size
 Data  = BYTARR(FileSize)		; Create a byte array, same size as file
 POINT_LUN, LUnit, 0			; Rewind the file
 READU, LUnit, Data			; Unformatted read of file into byte array
 CRLocs = WHERE(Data EQ 13, NumRecs)	; Number and location of carriage returns, ASCII 13
 IF (NumRecs LE 0) THEN $
  LFLocs = WHERE(Data EQ 10, NumRecs)	; Number and location of line feeds, ASCII 10
 POINT_LUN, LUnit, 0			; Rewind the file for completeness
 IF (Data(FileSize-1) EQ 10 OR Data(FileSize-1) EQ 13) THEN GOTO, finish
 IF ((Data(FileSize-1) EQ 26) AND $
    (Data(FileSize-2) EQ 10 OR Data(FileSize-1) EQ 13)) THEN GOTO, finish

 NumRecs = NumRecs + 1  		; If the last character is not a
					; carriage return or a line feed
					; and the second to last character
					; is not a carriage return or a
					; line feed then there is an extra
					; line
finish:
 RETURN, NumRecs
END
