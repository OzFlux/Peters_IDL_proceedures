pro OutDev, Device=Device, Title=Title, OutFile=OutFile, Path=Path, $
            Name=Name, Close=Close, NoWin=NoWin

; This procedure sets up the user selected output device.
; USAGE
;  OutDev, [Device={'vga','hpgl','pcl','cgm','hp3'}], [Title={String}], $
;          [OutFile={String}], [Path={String}], [Name={String}], $
;          [/close],[/nowin]
; INPUTS
;  Device	- graphics device to select
;  Title	- title of any new windows created if output is to
;		  the screen
;  OutFile	- name and path of the output file if output is to file
;  Path		- path of the output file if output is to file
;  Close	- close currently open files or windows
;  NoWin	- disable opening of new window if output is to screen
; OUTPUTS
;  Name		- a variable containing the output file name and path
; PROCEDURES CALLED
;  VGA		- VGA screen definitions file (C:\WINDOWS\IDL\LIB\ISAAC)
;  HPGL		- HPGL definitions file (C:\WINDOWS\IDL\LIB\ISAAC)
;  PCL		- PCL definitions file (C:\WINDOWS\IDL\LIB\ISAAC)
;  CGM		- CGM definitions file (C:\WINDOWS\IDL\LIB\ISAAC)
;  PICKFILE	- OS file name selection widget (C:\WINDOWS\IDL\LIB\USERLIB)
; WHAT DOES IT DO ?
;  Depends on keyword usage as below :
;  1) Device not specified
;	- if the current graphics device is not the screen, all open
;	  graphics files are closed and the screen is made the current
;	  graphics device
;	- if the Close keyword is specified, any open windows are closed
;	- the plots per page (!P.MULTI) and plot position (!P.POSITION)
;	  system variables are reset
;	- calls the VGA screen definitions file to set the screen as the
;	  current graphics device, load the 16 level colour table and
;	  define the colours
;  2) Device='vga'
;	- calls the VGA screen definitions file to set the screen as the
;	  current graphics device, load the 16 level colour table and
;	  define the colours
;	- if the NoWin keyword is not specified a new window is opened
;	  on the screen with the default dimensions
;	  - if the Title keyword is set, the title of the new window is
;	    set to the string contained in Title
;  3) Device='hpgl'
;	- if the Close keyword is not set
;	  - if the OutFile and Path keywords are not set, the user is
;	    prompted for the output file name via a File Save As
;	    dialogue box using the current default directory and with
;	    the '*.hgl' filter
;	  - if the OutFile keyword is not set but the Path keyword is set,
;	    the user is prompted for the output file name via a File Save
;	    As dialogue box with the path set to the string contained in
;	    the Path keyword and with the filter '*.hgl'
;	  - if the OutFile keyword is set, graphics output is sent to
;	    the file specified by the string contained in OutFile.  NOTE
;	    THAT IF OUTFILE IS SET, PATH HAS NO EFFECT.
;         - a variable, Name, is created containing the name
;	    of the output file
;	  - the HPGL definitions file is called with the output filename
;	    set to OutFile
;	- if the Close keyword is set
;	  - the current graphics device (should be an HPGL file but this
;	    is not checked in this version) is closed
;  4) Device='pcl'
;	- as for Device='hpgl' above but for PCL format files
;  5) Device='hp3'
;	- as for Device='pcl' above except that
;	  - if the Close keyword is set, the current graphics device is
;	    closed and the file contained in OutFile is spooled to
;	    LPT1 using the Lahey F77 programme BINPRN
;  6) Device='cgm'
;	- as for Device='hpgl' above but for CGM format files
;--------------------------------------------------------------------------

  IF NOT KEYWORD_SET(Device) THEN BEGIN		; No device specified so reset
   IF (!D.NAME NE 'WIN') THEN BEGIN		; Current device not screen
    PRINT, 'Closing graphics device ',!D.NAME
    DEVICE, /close				; Close any open files
   ENDIF
   vga						; Call the VGA definition file
   IF KEYWORD_SET(Close) THEN $			; No device but Close set
    WHILE !D.WINDOW GE 0 DO WDELETE		; so close any open windows
   !P.MULTI = 0					; Reset !P.MULTI sysvar
   !P.POSITION = 0				; Reset !P.POSITION sysvar
   GOTO, finish					; Exit procedure
  ENDIF						; End of reset

  IF (STRLOWCASE(Device) EQ 'vga') THEN BEGIN	; Output to screen
   vga						; Call the VGA definition file
   IF NOT KEYWORD_SET(NoWin) THEN BEGIN		; Create new window
    IF KEYWORD_SET(Title) THEN BEGIN		; Was title specified
     WINDOW, !D.WINDOW+1, title=Title		; Open a window with title
    ENDIF ELSE BEGIN				; No title specified
     WINDOW, !D.WINDOW+1			; Open window without title
    ENDELSE					; End of title choice
   ENDIF					; End of new window choice
  ENDIF						; End of VGA output

  IF (STRLOWCASE(Device) EQ 'hpgl') THEN BEGIN	; Output to HPGL file
   IF NOT KEYWORD_SET(Close) THEN BEGIN		; Open HPGL file
    IF NOT KEYWORD_SET(OutFile) THEN BEGIN	; Was file name specified
     IF NOT KEYWORD_SET(Path) THEN $		; Was path specified
      OutFile = PICKFILE(title='Save File As',filter='*.hgl') $
     ELSE $
      OutFile = PICKFILE(title='Save File As',path=Path,filter='*.hgl')
    ENDIF					; End of file name choice
    Name = OutFile				; Return the full output file name
    hpgl, OutFile				; Call the HPGL definition procedure
   ENDIF ELSE BEGIN				; Close HPGL file
    DEVICE, /close
    PRINT, 'Closing HPGL file ', OutFile
   ENDELSE					; End of open/close choice
  ENDIF						; End of HPGL file output

  IF (STRLOWCASE(Device) EQ 'hp3') OR $		; Output to HP3 printer
     (STRLOWCASE(Device) EQ 'pcl') THEN BEGIN	; or to PCL file
   IF NOT KEYWORD_SET(Close) THEN BEGIN		; Open PCL file
    IF NOT KEYWORD_SET(OutFile) THEN BEGIN	; Was file name specified
     IF NOT KEYWORD_SET(Path) THEN $		; Was path specified
      OutFile = PICKFILE(title='Save File As',filter='*.pcl') $
     ELSE $
      OutFile = PICKFILE(title='Save File As',path=Path,filter='*.pcl')
    ENDIF					; End of file name choice
    Name = OutFile				; Return the full output file name
    pcl, OutFile				; Call the PCL definition procedure
   ENDIF ELSE BEGIN				; Close PCL file
    DEVICE, /close
    PRINT, 'Closing PCL file ', OutFile
    IF (STRLOWCASE(Device) EQ 'hp3') THEN BEGIN	; HP3 printer
     CmdStr = 'binprn ' + OutFile		; DOS Command line to print
     SPAWN, CmdStr				; Spool PCL file
    ENDIF					; End of print choice
   ENDELSE
  ENDIF						; End of PCL file output

  IF (STRLOWCASE(Device) EQ 'cgm') THEN BEGIN	; Output to CGM file
   IF NOT KEYWORD_SET(Close) THEN BEGIN		; Open CGM file
    IF NOT KEYWORD_SET(OutFile) THEN BEGIN	; Was file name specified
     IF NOT KEYWORD_SET(Path) THEN $		; Was path specified
      OutFile = PICKFILE(title='Save File As',filter='*.cgm') $
     ELSE $
      OutFile = PICKFILE(title='Save File As',path=Path,filter='*.cgm')
    ENDIF					; End of file name choice
    Name = OutFile				; Return the full output file name
    cgm, OutFile				; Call the CGM definition procedure
   ENDIF ELSE BEGIN				; Close CGM file
    DEVICE, /close
    PRINT, 'Closing CGM file ', OutFile
   ENDELSE					; End of open/close choice
  ENDIF						; End of CGM file output

finish:
end
