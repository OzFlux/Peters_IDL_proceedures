PRO RSET_MASTER

starttime=systime(1,/SECONDS)

forward_function envi_get_data
forward_function ENVI_WRITE_ENVI_FILE
forward_function ENVI_OPEN_FILE
forward_function ENVI_LAYER_STACKING_DOIT
forward_function ENVI_FILE_MNG

;Set computer
uni = 'E:\DataE\'
home = 'C:\Data\'

;SET 1.
computer = home
;computer = uni

GrdSz = '14x14'     ; set to appropriate grid size for ascii cutout data (if applicable)
NULL_VALUE = -9999

FOR ft=2,2 DO BEGIN
DBG_NUM = 600 ; line counter for pausing and debugging
last_ENVISTACK3 = -1

IF ft EQ 0 THEN fluxtower = 'DalyUncleared'
IF ft EQ 1 THEN fluxtower = 'HowardSprings'
IF ft EQ 2 THEN fluxtower = 'Bondville'
IF ft EQ 3 THEN fluxtower = 'Griffin'
IF ft EQ 4 THEN fluxtower = 'Hainich'
IF ft EQ 5 THEN fluxtower = 'Hesse'
IF ft EQ 6 THEN fluxtower = 'Howland'
IF ft EQ 7 THEN fluxtower = 'MerBleue'
IF ft EQ 8 THEN fluxtower = 'Mize'
IF ft EQ 9 THEN fluxtower = 'MorganMonroe'
IF ft EQ 10 THEN fluxtower = 'NiwotRidge'
IF ft EQ 11 THEN fluxtower = 'NSAOldBlackSpruce'
IF ft EQ 12 THEN fluxtower = 'SantaremKm83'
IF ft EQ 13 THEN fluxtower = 'Tonzi'
IF ft EQ 14 THEN fluxtower = 'Tumbarumba'
IF ft EQ 15 THEN fluxtower = 'VirginiaPark'
IF ft EQ 16 THEN fluxtower = 'WalnutRiver'
IF ft EQ 17 THEN fluxtower = 'FoggDam'

in_path = computer+'Satellite\MODIS\'+fluxtower+'ASCIIcutouts\STACKS500m\'
out_path =computer+'Satellite\MODIS\'+fluxtower+'ASCIIcutouts\RSET_RESULTS\'

CD, in_path

stacklist = FILE_SEARCH('*MODSTACK.hdr'); starting off with the stacks for Terra
FOR N = 0,  n_elements(stacklist)-1 DO BEGIN

	CLOSE, /ALL, /FORCE		; frees all allocated LUNs and prevents memory overflow

	first_metfile_avg = 1
	input_name = stacklist(N)
	in_filename = in_path + input_name
	date = STRMID(input_name, 10,7)
	Sdate = STRMID(input_name, 9,8); LST 8 day dataset first day date
	Vdate = STRMID(input_name, 0,8); Vegetation Index 16 day dataset first day date

in_path_MET = computer+'FluxData\'+fluxtower+'\'
METfile = fluxtower+'IDL.csv'
inMETfile = in_path_MET + METfile
MET=readmet(inMETfile)

in_path_Tower = computer+'FluxData\'
Towerfile = 'SitesSummary.csv'
inTowerfile = in_path_Tower + Towerfile
TowerHeader=readtowerheader(inTowerfile)
;
;MET8day=calc8dayMET(MET)


ENDFOR; N loop
ENDFOR; ft loop


endtime=systime(1,/SECONDS)
Runningtime=endtime-starttime
print, 'finished in ', Runningtime, ' seconds'

END