Scriptname WeirdArtifactsGoldspillManagerSCRIPT extends Quest

WeirdArtifactsGoldspillCounter Property WeirdArtifactsGoldspillCounterREF Auto

Bool _bWaitingForTriggerToStart = false
Int  _iActorsSpilling = 0

Int Function GetRemainingSpillBudget()
   If !WeirdArtifactsGoldspillCounterREF.IsMonitoring()
      _StartMonitoringAndWait()
   EndIf
   Int iExtantCoinGroups = WeirdArtifactsGoldspillCounterREF.Count()
   Int iMaxCoinGroups    = 250
   If iExtantCoinGroups > iMaxCoinGroups
      Return 0
   EndIf
   Return iMaxCoinGroups - iExtantCoinGroups
EndFunction

Function OnGoldSpilled(Int aiNewCoinGroupCount)
   WeirdArtifactsGoldspillCounterREF.StartMonitoring()
   ;
   ; If we go this many seconds without any more gold being spilled, then deactivate 
   ; our gold-counting trigger.
   ;
   Self.RegisterForSingleUpdate(60.0)
EndFunction
Event OnUpdate()
   WeirdArtifactsGoldspillCounterREF.StopMonitoring()
EndEvent

;
; Communication from our counter trigger:
;

Function _StartMonitoringAndWait()
   If _bWaitingForTriggerToStart
      Return
   EndIf
   _bWaitingForTriggerToStart = True
   WeirdArtifactsGoldspillCounterREF.StartMonitoring()
   
   Bool bTimedOut = False
   Int  iWaits    = 0
   While !_bWaitingForTriggerToStart && !bTimedOut
      Utility.Wait(0.25)
      iWaits += 1
      If iWaits == 4 ; i.e. time out after 1 second
         bTimedOut = True
      EndIf
   EndWhile
   If !bTimedOut
      ;
      ; Give the trigger time to actually count any already-present coin groups:
      ;
      Utility.Wait(1.00)
   EndIf
EndFunction
Function OnMonitoringStarted()
   _bWaitingForTriggerToStart = False
EndFunction
