;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                CIDC  READ Program (written in IDL Language)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Most of the Goddard DAA; interdisciplinary Data Set are generated in
; binary form.Each word is a 4 byte floating in IEEE Std 754 format(IEEE
; Standard for binary floating-point Arithmetic).
;
; HP,SGI,IBM and Motorola 68000 systems store multibyte values in
; BIG-Endian order (where the most significant  bytes are on the left most)
; Intel 80x86based PC's, DEC Alpha and VAX systems store them in
; Little-Endian order where most significant bytes are on the right most)
;
; Since our dataset is generated on SGI unix machine(Big-Endian architecture)
; The readers on Little-Endian machines need to perform byte swapping.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    For running it on big-endian type machines,
;    type:
;           idl
;           .run readcidc.pro
;           readcidc
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ATTENTION PC c VAX and Dec Alpha  users!!!
;
; Byte swapping is needed .
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  For comments and suggestions, Please contact:
;                                           Dr. Suraiya Ahmad
;                                          ahmad@eosdata.gsfc.nasa.gov
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Last update:  Thurs March 26, 1998 11:30 a.m
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;           Welcome to Goddard DAAC; Climate Data Base
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; CIDC Binary Products:on 1*1 deg grids
;  all paramteres except few   : filesize= 4*(360*180*1) =  259,200 Bytes
;
; TOVS Products: on 1*1 deg grids
;  Surface   paramteres        : filesize= 4*(360*180*1) =  259,200 Bytes
;  Cltemp(4 levels,surfc=1)    : filesize= 4*(360*180*4) = 1036,800 Bytes
;  Prwat (5 levels,surfc=1)    : filesize= 4*(360*180*5) = 1296,000 Bytes
;  Fcld7 (7 layers,top=1)      : filesize= 4*(360*180*7) = 1814,400 Bytes
;
; DAO (Data Assimilation Office) Products: on 2*2 deg grids (claculated at
; int lat/lon values it is not at the center of grid)
;
;  Surface paramteres          : filesize= 4*(180*91*1)  =   65,520 Bytes
;  uwnd,vwnd(8 levels,surfc=1) : filesize= 4*(180*91*8)  =  524,160 Bytes
;  hght,tmpu(8 levels,surfc=1) : filesize= 4*(180*91*8)  =  524,160 Bytes
;  sphu     (8 levels,surfc=1) : filesize= 4*(180*91*8)  =  524,160 Bytes
;
; E-anglia Temperature Deviations: 5x5 grids
;  individual monthly          : filesize= 4*(72*36*1)   = 10,368   Bytes
;  decadal monthly             : filesize= 4*(72*36,*120)= 1244,160 Bytes
;
; Smmr_monsoon: on 1*1 deg grids (latitude: 30 to -30,longtd 30E to 200E )
;  precipitation               : filesize=4*(171,61,1)    = 41724 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
 Pro readcidc
;

  common datgrd, nbytes, nlayer, ltgrid, lngrid, dellat, dellon

;
      print,' '
      print,'Goddard DAAC Interdiscipline Climate Data Read Program'
      print,' '




; Initialize Variables


         yn=' '
         infile=' '


         lngrid=360
         ltgrid=180
         dellon=1.0
         dellat=1.0
         nlayer=1
         nbytes=259200


;
;;;;;;;;;;;;;;;;;;;;;;;

        print, 'please,enter input file name:'
        read,infile
        print, ' You entered for the input file name : ', infile


        print,'enter total number of grids along longitude:  '
        read,lngrid


        print,'enter total number of grids along the latitude:  '
        read,ltgrid

        print,'enter longitude grid increment(in deg) :'
        read,dellon
        print,'enter latitude grid increment (in deg) :  '
        read,dellat
        print,' '
        print, 'you entered total longrid  = ',lngrid, '    dellon= ',dellon
        print, 'you entered total latgrid  = ',ltgrid, '    dellat= ',dellat
        print,' '


        print,'please, enter number of layers or subsets in your file:'
        print,'  = 1 for most of our data'
        print,'  = 1,4,5 or 7 For TOVS'
        print,'  = 1 or 8 For DAO and'
        print,'  = 120 For East Anglia decades temperature dev :  '
        read,nlayer
        print, ' You enetered for the total layer : ', nlayer


;
; Initialize Arrays
;

         buff=fltarr(lngrid,ltgrid,nlayer)
         nbytes= 4* (lngrid*ltgrid*nlayer)

;;;;;;;;;;;;;;;;;;;;;;;;

      openr,in_unit,infile,/get_lun
      readu,in_unit, buff

       close,in_unit
       free_lun,in_unit
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; To view, print data at every 10th latitude index and for 4 longitude values


      print,' '
      print,'To view data is printed for every 10th latitude index '
      print,' and for four longitude index'

      nxdel=lngrid/4

	mlayer=nlayer-1

	for klyr=0,mlayer do begin

	   print,' '
	   print,'layer or level number = ',klyr+1


      for j=0,ltgrid-1,10 do begin

       i1=0
       i2=i1+nxdel
       i3=i2+nxdel
       i4=i3+nxdel
      print,format='((1x,i5,1x,4(i5,1x,f11.3)))',j,i1+1,buff(i1,j,klyr),$
                         i2+1,buff(i2,j,klyr),i3+1,buff(i3,j,klyr),$
                         i4+1,buff(i4,j,klyr)
       endfor



; print max and min
;
    min1=min(buff)
    min2=min(buff(where(buff GT min1)))
    min3=min(buff(where(buff GT min2)))

    max1=max(buff)
    max2=max(buff(where(buff LT max1)))
    max3=max(buff(where(buff LT max2)))

  print, 'Three Lowest values= ',min3,min2,min1
  print,'Three Highest values=',max3,max2,max1

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Procedure Subset is called to
;  Extract a Subset of Data and
;  write it in a file in Ascii
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
        subset, buff,klyr
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

         endfor                   ; end of the klayer loop

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
       print ,'Job finished successfully'

       print ,' '

       end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Procedure Subset:
;
;   Extracts a Subset of Data and writes it in a file in the Ascii form
;  intended for Excel/Lotus or other  data analysis softwares
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 pro subset, buff, klyr

   common datgrd, nbytes, nlayer, ltgrid, lngrid, dellat, dellon

; Initialize arrays and variables

       yn=' '
       otfile=' '
       hdbuff=fltarr(360)
       nsub=0

      print,' '
      print,'Do you want a subset of data in ascii form?(y/n):'
      read,yn
      if(yn eq 'y'  or  yn eq 'Y')then nsub=1
      if (nsub eq 0)then goto, finish

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print,' '

 	print,' Please Enter the name of the output file'
 	print,' You may enter short file name or if you wish enter'
        print,' full name including the path and directory(upto 72 characters)'
        print,' e.g.  /usr/people/ahmad/cidc/test.out'
        read,otfile

       print, 'You entered for the output file name: ',otfile
       print,' '
;
;;;;;;;;;;;;;;;  open the output file for write the subset
;
      openw,out_unit,otfile,/get_lun

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      print,' '
      print,'Be Ready to enter latitude and longitude in degrees '
      print,'Enter starting latitude value, blank spaces'
      print,'and then ending latitude value ,  '
      print,'for North latitudes use +ve for South to the equator use -ve'
      print,'e.g for starting from 10 degree North to 5 degree South, enter: 10   -5'
      read,strtlt,endlt

      print,'you have entered: '
      print,'starting latitude =',strtlt, ';  ending latitude =',endlt

;;;
      print,' '
      print,'Enter starting longitude value, blank spaces '
      print, 'and then ending longitude '
      print,'for longitude West to Greenwich use negative sign,'
      print,'e.g for starting from 2 degree West to 3 degree East enter: -2    3'
      read,strtln,endln

;;;;
      print,'you have entered: '
      print,'starting longitude =',strtln, '  ;  ending longitude =',endln


;;;;;;;;;;;;; convert user's lat and lon into data index

              latdel=fix(0.1+dellat)
              ltnm1=1+(90-strtlt)/latdel
              ltnm2=1+(90-endlt)/latdel

              londel=fix(0.1+dellon)
              lnnm1=1+(180+strtln)/londel
              lnnm2=1+(180+endln)/londel

;
;ssssss for smmr monsoon only
;
;  SMMR Monsoon Rain (hydrology/precip/..) for limited area
; latitude range= 30 to -30 ; longitude range 30 East to 200 East

;
               if(nbytes eq 41724)then begin
	          ltnm1=1 + (30-strtlt)/latdel
                ltnm2=1 + (30-endlt)/latdel
                lnnm1=1 + ((-30)+strtln)/londel
                lnnm2=1 + ((-30)+endln)/londel
	if(lnnm1  lt  0  or  lnnm2  lt  0)then goto, restart
               endif
;
;sssssssssssssssss
;              print , strtlt,endlt,ltnm1,ltnm2
;              print , strtln,endln,lnnm1,lnnm2

              if(ltnm1 gt 180)then ltnm1=180
              if(ltnm2 gt 180)then ltnm2=180
              if(lnnm1 gt 360)then lnnm1=360
              if(lnnm2 gt 360)then lnnm2=360
;
              j1=ltnm1
              j2=ltnm2

              nlt=ltnm1-ltnm2

               if (nlt gt 0)then begin
               j1=ltnm2
               j2=ltnm1
               endif

;;;
             i1=lnnm1
             i2=lnnm2

             nln=lnnm1-lnnm2

               if (nln gt 0)then begin
               i1=lnnm2
               i2=lnnm1
               endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       	     print,' '
             print,'Data layer or level number=',klyr+1
             printf,out_unit,klyr+1


; print as colum heading the longitude values in deg.
;

                 for i=i1,i2 do begin
                 alonn=-180 + (i-1)*londel
	         if(nbytes eq 41724)then alonn=30+(i-1)*londel
                 hdbuff(i-1)=alonn
                 endfor

            print,format='(//1x,6x,360(1x,f8.1,3x))',hdbuff(i1-1:i2-1)
            printf,out_unit,format='(//1x,6x,360(1x,f8.1,3x))',hdbuff(i1-1:i2-1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Print data starting from second column
;;; first column is latitude values in degrees
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

        for  j = j1,j2 do begin

          alatt=90- (j-1)*latdel
	  if(nbytes eq 41724)then alatt=30- (j-1)*latdel

          print,format='(1x,f6.1,360(f12.4))',alatt,buff(i1-1:i2-1,j-1,klyr)
          printf,out_unit,format='(1x,f6.1,360(f12.4))',alatt,buff(i1-1:i2-1,j-1,klyr)

       endfor
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

       close,out_unit
       free_lun,out_unit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      goto, finish
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  restart:
           print,'SMMR monsoon data is available for the range 30 to 200'
	   print,'East, and 30 N to 30 S only.'
	   print,'Check your input and run again'
	   exit

 finish:
          return
          end



