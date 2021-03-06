PRO ByteToNDVI
; AUTHOR: PRI
; DATE: Unknown
; PURPOSE:
;  Reads the image-interleaved format (.IIL) file produced by BIL2IIL.PRO
;  and converts the byte values to the spectral radiances, see the comments
;  under METHOD for details of the calibration method and the sources of
;  this information.  The NDVI is then calculated from the spectral
;  radiances in TM bands 3 and 4, written to file and the image plotted
;  to the screen.
; INPUTS:
; OUTPUTS:
; METHOD:
;  Pass details:
;   Date          8/10/95
;   Time          23:03:22 UT
;   Path/row      92/84
;   Orbit         61720
;   Sun elevation 40.2 deg
;   Sun azimuth   65.3 deg
;   Centre lat    34 deg 36' 51" S
;   Centre lon    146 deg 47' 01" E
;
;  The ACRES web site ("http://www.auslig.gov.au/acres/reference/pro.levs.htm")
;  states that:
;   "The absolute radiometric calibration of data involves the conversion
;    of the pixel brightness values into units of spectral radiance.  This
;    type of calibration is not done for any ACRES products, and if required,
;    must be performed by the user."
;
;  The same web site says that the only calibration performed on ACRES products
;  is a "relative" calibration where the output from each of the 16 detectors
;  used for each band is adjusted so that all detector outputs for a given
;  band cover the same dynamic range.
;
;  The calibration model adopted here converts the byte values in the BIL file
;  to radiances using:
;   L = Gain*BV + Offset
;  where BV is the byte value.  The radiance is then converted to the reflectance
;  using:
;   P = Pi*L/(d^2*E*cos(theta))
;  where L is the radiance, E is the solar irradiance in the TM band, theta
;  is the solar zenith angle and d accounts for the variation in sun-earth
;  distance given by:
;   d = 1.0/(1.0-0.016729*cos(0.9856*(DOY-4)))
;  and DOY is the day of the year on which the Landsat pass occured.
;
;  Note that no atmospheric correction is made.
;
;  The following gain and offset values come from the web page:
;   http://earth.esa.int/rootcollection/sysutil/008e3.html
;  which quotes;
;   Arino O, Brockmann C, Versini B & Pittella G, 1994
;   "ESA products and processing algorithms for Landsat-TM"
;   ESA Technical Note TM-TN-DPE-OT-OA- 001, 31 May 1994, 15 pp.
;  Note that an updated set of calibration values is available from:
;   http://edc.usgs.gov/products/satellite/tm.html#L5radiometry
;   URL: http://edc.usgs.gov//products/satellite/tm.html
;   Maintainer: EDC Web Master email at edcweb@usgs.gov
;   Last Update:Tuesday, September 23, 2003
;   Accessed:Friday 7 November 2003
;  as a PDF file called L5TMCal2003.pdf.  This seems to be the
;  latest version of Landsat 5 TM radiometer calibrations.
; USES:

Gain = [0.731,1.353,0.971,1.069,0.143,1.0,0.076]
OffSet = [-1.5,-3.1,-2.7,-2.5,-0.45,0.0,-0.3]
; Centre wavelength of the TM bands.
Centre = [486.0,570.0,660.0,830.0,1676.0,0.0,2210.0]
; Solar irradiance in the TM bands.
Solar = [1957.0,1829.0,1557.0,1047.0,219.3,0.0,74.52]

Pi = 3.141593
theta = 50.0*Pi/180.0
DOY = 281.
d = 1.0/(1.0-0.016729*cos(0.9856*(DOY-4.0)))

InLun = GetLun()
openr, InLun, 'e:\oasis95\landsat\data\wt.iil'
TM = assoc(InLun, bytarr(5202,2002))

; Get the reflectance in band 3.
P3 = Gain(2)*float(TM(2)) + OffSet(2)
P3 = Pi*temporary(P3)/(d^2*Solar(2)*cos(theta))
; Get the reflectance in band 4.
P4 = Gain(3)*float(TM(3)) + OffSet(3)
P4 = Pi*temporary(P4)/(d^2*Solar(3)*cos(theta))

; Close the input file and clear the associated variable.
free_lun, InLun
TM = 0

; Now we get the normalised difference vegetation index, NDVI, using
; TM bands 3 and 4.
NDVI = (P4 - P3)/(P4 + P3)
P3 = 0
P4 = 0

; Lakes and rivers give rise to negative values of NDVI, we trap these
; and set them to 0.
NDVI(where(NDVI lt 0.0)) = 0.0

; Now write the NDVI to file.
OutLun = GetLun()
openw, OutLun, 'e:\oasis95\landsat\data\ndvi.dat'
writeu, OutLun, NDVI
free_lun, OutLun

; Now we scale and equalise the NDVI and display the result.
NDVI = bytscl(NDVI)
NDVI = hist_equal(NDVI)
slide_image, NDVI, title='OASIS95 NDVI : Full Resolution', congrid=0, order=1, show_full=0, $
                xvisible=700, yvisible=700

end
