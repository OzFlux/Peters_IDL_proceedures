    SubVEG = [VEG1988[C1:C2,R1],REFORM(VEG1988[C2,R1:R2]),$
              VEG1988[C1:C2,R2],REFORM(VEG1988[C1,R1:R2])]
    SubLAI = [LAI1988[C1:C2,R1],REFORM(LAI1988[C2,R1:R2]),$
              LAI1988[C1:C2,R2],REFORM(LAI1988[C1,R1:R2])]
    SubInd = WHERE(SubVEG EQ VType, Count)
    IF Count NE 0 THEN BEGIN
     S = SIZE(LAIValues)
     IF S[0] EQ 0 THEN LAIValues = SubLAI[SubInd] ELSE LAIValues = [LAIValues,SubLAI[SubInd]]
    ENDIF
    NumFound = NumFound + Count
