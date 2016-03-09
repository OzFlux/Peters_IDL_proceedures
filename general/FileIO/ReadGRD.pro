PRO ReadGRD, GRDFileName, MetaData, Data

; PURPOSE
;  Reads a Surfer .GRD format file and returns two arrays, one containing
;  the data itself and the other containing the number of columns, the
;  number of rows and the minimum and maximum X, Y and Z coordinates.
; INPUT
;  The filename of a .GRD format file.
; OUTPUT
;  Returns two arrays of single precision floating point data.  Note that the
;  binary .GRD file format uses double precision, the file is read at this
;  precision and the conversion to single precision is done in this routine.
;  Contents of MetaData are as follows:
;   MetaData[0] - number of columns in grid
;   MetaData[1] - number of rows in grid
;   MetaData[2] - minimum X coordinate of grid
;   MetaData[3] - X cell size
;   MetaData[4] - minimum Y coordinate of grid
;   MetaData[5] - Y cell size
;   MetaData[6] - minimum Z value of grid
;   MetaData[7] - maximum Z value of grid
;   MetaData[8] - rotation (not currently used by Surfer)
;   MetaData[9] - blanking value (1.70141E+38)
; DESCRIPTION
;  Some notes about Surfer .GRD files and image display and array
;  subscript order in IDL.
;  1) Surfer .GRD files in ASCII format start with 5 header lines followed
;     by the grid data in row/column format.  The first row of data corresponds
;     to the minimum Y coordinate and the last row corresponds to the maximum
;     Y coordinate.
;  2) Surfer .GRD files in binary format (V7) start with a header section
;     followed by the grid data in row major order and, as with the ASCII
;     format files, the first row corresponds to the minimum Y coordinate.
;  3) the IDL routines for displaying image data (TV, TVSCL) plot the image
;     from the top down, that is, the first row of the image array is plotted
;     at the top of the display window and the last row of the image is
;     plotted at the bottom of the display window.  This is consistent with the
;     order in which the rows of data are stored in the Surfer .GRD files.
;  4) (more here later)
; LIMITATIONS
;  Only reads Surfer V7 and higher binary files, Surfer V6 and lower
;  binary files are not supported.  Version checking not implemented.
; AUTHOR
;  Peter Isaac
; DATE
;  19 January 2005

; *** Declare constants and type variables.
  BlockHeader = '1234'
  BlockLength = LONG(0)
  Version = LONG(0)
  NCol = LONG(0)
  NRow = LONG(0)
  xLL = DOUBLE(0.0)
  yLL = DOUBLE(0.0)
  xSize = DOUBLE(0.0)
  ySize = DOUBLE(0.0)
  xMin = DOUBLE(0.0)
  yMax = DOUBLE(0.0)
  yMin = DOUBLE(0.0)
  yMax = DOUBLE(0.0)
  zMin = DOUBLE(0.0)
  zMax = DOUBLE(0.0)
  Rotation = DOUBLE(0.0)
  BlankValue = DOUBLE(0.0)

; *** Open the input .GRD file, read the first 4 bytes of the file and
; *** check to see if the file is text or binary.
  GRDLun = GETLUN()
  OPENR, GRDLun, GRDfileName
  READU, GRDLun, BlockHeader
  FREE_LUN, GRDLun
  CASE BlockHeader OF
   'DSRB': BEGIN
     PRINT, GRDFileName, ' will be read as a binary .GRD file'
     OPENR, GRDLun,GRDFileName
     READU, GRDLun,BlockHeader,BlockLength,Version
     READU, GRDLun,BlockHeader,BlockLength,NRow,NCol,xLL,yLL,xSize,ySize,zMin,zMax,Rotation,BlankValue
     MetaData = MAKE_ARRAY(10, /FLOAT)
     MetaData[0] = FLOAT(NCol)			; Number of columns
     MetaData[1] = FLOAT(NRow)			; Number of rows
     MetaData[2] = FLOAT(xLL)			; X minimum
     MetaData[3] = FLOAT(xSize)			; X cell size
     MetaData[4] = FLOAT(yLL)			; Y minimum
     MetaData[5] = FLOAT(ySize)			; Y cell size
     MetaData[6] = FLOAT(zMin)			; Z minimum
     MetaData[7] = FLOAT(zMax)			; Z maximum
     MetaData[8] = FLOAT(Rotation)		; Rotation angle
     MetaData[9] = FLOAT(BlankValue)	; Blanking value
     Data = MAKE_ARRAY(NCol, NRow, /DOUBLE)
     READU, GRDLun,BlockHeader,BlockLength,Data
;     Data = FLOAT(REVERSE(Data, 2))
     Data = FLOAT(Data)					; Convert to single precision floating point
    END
   'DSAA': BEGIN
     PRINT, GRDFileName, ' will be read as a text .GRD file'
     OPENR, GRDLun, GRDFileName
     READF, GRDLun, BlockHeader
     READF, GRDLun, NCol, NRow
     READF, GRDLun, xMin, xMax
     READF, GRDLun, yMin, yMax
     READF, GRDLun, zMin, zMax
     MetaData = MAKE_ARRAY(10, /FLOAT)
     MetaData[0] = FLOAT(NCol)					; Number of columns
     MetaData[1] = FLOAT(NRow)					; Number of rows
     MetaData[2] = FLOAT(xMin)					; X minimum
     MetaData[3] = FLOAT((xMax-xMin)/(NCol-1))	; X cell size
     MetaData[4] = FLOAT(yMin)					; Y minimum
     MetaData[5] = FLOAT((yMax-yMin)/(NRow-1))	; Y cell size
     MetaData[6] = FLOAT(zMin)					; Z minimum
     MetaData[7] = FLOAT(zMax)					; Z maximum
     MetaData[8] = FLOAT(0.0)					; Rotation angle
     MetaData[9] = FLOAT(1.70141E38)			; Blanking value
     Data = MAKE_ARRAY(NCol, NRow, /DOUBLE)
     DataLine = MAKE_ARRAY(NCol, /DOUBLE)
     FOR i=0, NRow-1 DO BEGIN
      READF, GRDLun, DataLine
      Data[*,i] = DataLine
     ENDFOR
;     Data = FLOAT(REVERSE(Data, 2))
     Data = FLOAT(Data)
    END
   ELSE: PRINT, 'Unrecognised .GRD file type'
  ENDCASE

; *** Close the file and return.
  FREE_LUN, GRDLun

END