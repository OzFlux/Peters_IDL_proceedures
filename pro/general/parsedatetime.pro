function parsedatetime, s, year, month, day, hour, minute, second

false=0
true=1

result=str_sep(s,' ')
if (nele(result) eq 2) then begin      ; both date and time entered
 datestr=str_sep(result[0],'/')        ; process the date string
 if (nele(datestr) ne 3) then begin
  print, 'Incorrect date/time format'
  return, false
  endif
 day=fix(datestr[0])
 month=fix(datestr[1])
 year=fix(datestr[2])
 timestr=str_sep(Result[1],':')        ; process the time string
 if (nele(timestr) ne 3) then begin
  print, 'Incorrect date/time format'
  return, false
  endif
 hour=fix(timestr[0])
 minute=fix(timestr[1])
 second=fix(timestr[2])
endif else begin                       ; assume only the date was entered
 datestr=str_sep(result[0],'/')        ; process the date string
 if (nele(datestr) ne 3) then begin
  print, 'Incorrect date/time format'
  return, false
  endif
 day=fix(datestr[0])
 month=fix(datestr[1])
 year=fix(datestr[2])
 hour=0
 minute=0
 second=0
endelse

return, true

end