PRO ASCToGRD

; PURPOSE
;  Procedure to convert files of LAI data in .ASC format
;  to files of .GRD format used by Surfer.
; INPUT
;  Input files are LAI data in .ASC format.  These files are
;  ASCII and contain 6 header lines followed by rows of data.
;  The .ASC files appear to have been generated from the original
;  ArcView .FLT and .HDR files obtained from Geoscience Australia.
; OUTPUT
;  Output files are LAI data in .GRD format for use with Surfer,
;  see the Surfer help for a description of this format.
; DESCRIPTION
;  Notes
;  1) the LAI values for sea (all water bodies?) in the
;     .ASC files is set to a value of -9999.  Values of -9999 are
;      changed to the Surfer blanking value of 1.70141E38 before
;      the .GRD file is written so that grid cells with this value
;      are not plotted by Surfer.
;  2) the .GRD files are output as binary by default to reduce the
;     file size and speed up reading by Surfer.
; USES
;  ReadASC
;  WriteGRD
; AUTHOR
;  Peter Isaac
; DATE
;  16 January 2005

; *** Set some constants.
  BlankValue = 0.	; 1.70141E+38
  AdjToCentre = 'Y'	; Adjust minimum X and Y values to cell centre

; *** Get the input and output file names.
  Title = 'Select .ASC file'
  Filter = '*.asc'
  Path = 'C:\PROJECTS\CCAM\VEGETATION\LAI\1988'
  ASCFile = DIALOG_PICKFILE(TITLE=Title,FILTER=Filter,PATH=Path)
  IF ASCFile EQ '' THEN GOTO, Finish
  ExtPosition = RSTRPOS(ASCFile,'.') + 1
  GRDFile = ASCFile
  STRPUT, GRDFile, 'grd', ExtPosition
  PRINT, ASCFile, ' will be converted to ',GRDFile

; *** Read the .ASC file.
  ReadASC, ASCFile, MetaData, Data
; *** Print out the metadata for the Surfer grid file.
  PRINT, 'Cols, Rows ', MetaData[0], MetaData[1]
  PRINT, 'XMin, XSize ', MetaData[2], MetaData[3]
  PRINT, 'YMin, YSize ', MetaData[4], MetaData[5]
  PRINT, 'ZMin, ZMax ', MetaData[6], MetaData[7]
  PRINT, 'Rot, Blank ', MetaData[8], MetaData[9]
; *** Change the NODATA value used in the .ASC file to the blanking value
; *** used by Surfer.
  Index = WHERE(Data EQ MetaData[9], Count)
  PRINT, MetaData[9], Count
  IF Count NE 0 THEN Data[Index] = BlankValue
  MetaData[9] = BlankValue
; *** Adjust the minimum X and Y values.
  IF (AdjToCentre EQ 'Y' OR ADjToCentre EQ 'y') THEN BEGIN
   MetaData[2] = MetaData[2]+MetaData[3]/2.
   MetaData[4] = MetaData[4]+MetaData[5]/2.
  ENDIF
; *** Write the data to a .GRD file.
  WriteGRD, GRDFile, MetaData, Data, FORMAT='F4.1'

Finish:
END