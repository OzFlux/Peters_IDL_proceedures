PRO GetGen, GenFile, Defn, Runs

  IF (N_ELEMENTS(GenFile) EQ 0) THEN $
   GenFile = DIALOG_PICKFILE(Title='Select a definitions file',Path='C:\PROGRA~1\IDL52\GENERAL\DEFFILES')
  WAIT,0.1
  IF (STRLEN(GenFile) EQ 0) THEN RETALL
; *** Define the structures returned by this routine that contain the information
; *** from the definitions file.
  Defn = {Type:'',Root:'',Stat:''}
  Runs = {Date:STRARR(50),ACDay:STRARR(50),ID:STRARR(50),Src:STRARR(50), $
               STime:FLTARR(50),FTime:FLTARR(50),No:0}
  Line = ''
; *** Read the include file.
  GenLun = GetLun()
  OPENR, GenLun, GenFile
  WHILE NOT EOF(GenLun) DO BEGIN
   READF, GenLun, FORMAT='(A)', Line
   Line = CleanString(Line)
   Chr = STRMID(Line,0,1)
   Len = STRLEN(Line)
   IF Chr NE ';' AND Chr NE 'c' AND Chr NE 'C' AND Chr NE '!' AND Len GT 0 THEN BEGIN
    Parts = STR_SEP(Line,' ')
    CASE STRLOWCASE(Parts(0)) OF
     '[definitions]': GetDef, GenLun, Defn
     '[runs]':        GetRun, GenLun, Runs
    ELSE: PRINT, 'GetGen: Unrecognised keyword "',STRTRIM(Line,2),'"'
    ENDCASE
   ENDIF
  ENDWHILE
  FREE_LUN, GenLun

END
