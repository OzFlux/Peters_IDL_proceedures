;
; IDL Widget Interface Procedures. This Code is automatically
;     generated and should not be modified.

;
; Generated on:	01/19/102 16:14.42
;
pro SelectGraphicsOutput_event, Event

  wWidget =  Event.top

  case Event.id of

    Widget_Info(wWidget, FIND_BY_UNAME='PBtn_CGMFile'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        CGMFile, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='PBtn_Printer'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        Printer, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='PBtn_Continue'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        None, Event
    end
    else:
  endcase

end

pro SelectGraphicsOutput, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_

  Resolve_Routine, 'SelectGraphicsOutput_eventcb'

  SelectGraphicsOutput = Widget_Base( GROUP_LEADER=wGroup,  $
      UNAME='SelectGraphicsOutput' ,SCR_XSIZE=230 ,SCR_YSIZE=85  $
      ,TITLE='Output graphics to ...' ,SPACE=3 ,XPAD=3 ,YPAD=3  $
      ,TLB_FRAME_ATTR=2)


  PBtn_CGMFile = Widget_Button(SelectGraphicsOutput,  $
      UNAME='PBtn_CGMFile' ,FRAME=1 ,XOFFSET=10 ,YOFFSET=15  $
      ,SCR_XSIZE=60 ,SCR_YSIZE=25 ,/ALIGN_CENTER ,VALUE='CGM File')


  PBtn_Printer = Widget_Button(SelectGraphicsOutput,  $
      UNAME='PBtn_Printer' ,FRAME=1 ,XOFFSET=80 ,YOFFSET=15  $
      ,SCR_XSIZE=60 ,SCR_YSIZE=25 ,/ALIGN_CENTER ,VALUE='Printer')


  PBtn_Continue = Widget_Button(SelectGraphicsOutput,  $
      UNAME='PBtn_Continue' ,FRAME=1 ,XOFFSET=150 ,YOFFSET=15  $
      ,SCR_XSIZE=60 ,SCR_YSIZE=25 ,/ALIGN_CENTER ,VALUE='None')

  Widget_Control, /REALIZE, SelectGraphicsOutput

  XManager, 'SelectGraphicsOutput', SelectGraphicsOutput

end
;
; Empty stub procedure used for autoloading.
;
pro SelectGraphicsOutput, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  SelectGraphicsOutput, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
end
