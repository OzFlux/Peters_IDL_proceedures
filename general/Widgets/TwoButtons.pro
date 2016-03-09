; 
; IDL Widget Interface Procedures. This Code is automatically 
;     generated and should not be modified.

; 
; Generated on:	01/17/102 20:48.07
; 
pro TwoButtons_event, Event

  wWidget =  Event.top

  case Event.id of

    Widget_Info(wWidget, FIND_BY_UNAME='TwoButtons'): begin
    end
    Widget_Info(wWidget, FIND_BY_UNAME='OK_Button'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        OK, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='Cancel_Button'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        Cancel, Event
    end
    else:
  endcase

end

pro TwoButtons, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_

  Resolve_Routine, 'TwoButtons_eventcb'     ; Load event callback routines
  
  TwoButtons = Widget_Base( GROUP_LEADER=wGroup, UNAME='TwoButtons'  $
      ,SCR_XSIZE=193 ,SCR_YSIZE=102 ,KILL_NOTIFY='OK' ,TITLE='Choose'+ $
      ' One' ,SPACE=3 ,XPAD=3 ,YPAD=3)

  
  OK_Button = Widget_Button(TwoButtons, UNAME='OK_Button' ,XOFFSET=23  $
      ,YOFFSET=24 ,/ALIGN_CENTER ,VALUE='OK')

  
  Cancel_Button = Widget_Button(TwoButtons, UNAME='Cancel_Button'  $
      ,XOFFSET=99 ,YOFFSET=25 ,/ALIGN_CENTER ,VALUE='Cancel')

  Widget_Control, /REALIZE, TwoButtons

  XManager, 'TwoButtons', TwoButtons  ,CLEANUP='OK'  

end
; 
; Empty stub procedure used for autoloading.
; 
pro TwoButtons, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  TwoButtons, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
end
