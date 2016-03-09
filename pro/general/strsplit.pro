function strsplit,str,dlim,extract=extract,count=count

substr=str_sep(str,dlim)
count=nele(substr)
if keyword_set(extract) then return, substr else return, count

end