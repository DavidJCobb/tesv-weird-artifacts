Scriptname WeirdArtifactsGoldspillCoinGroup extends ObjectReference

MiscObject Property Gold001 Auto

;/
   Script for a "coin group:" a single ref whose NIF contains multiple Havok-simulated 
   coins. Activating any coin in the ref will cause an actor to pick up that many coins. 
   Essentially this is a way to work around issues with Papyrus and stack dumping, by 
   allowing the "Goldspill" effect to spill just as many coins but in the form of fewer 
   refs (and thus fewer Papyrus call stacks queued by the coin-counting trigger).
/;

Bool _bPickedUp = False

; Function used so we can update it in the future, to match the NIF, by editing the 
; script source code.
Int Function GetCoinCount() Global
   Return 5
EndFunction

Event OnInit()
   Cell kCell = Self.GetParentCell()
   If !kCell || !kCell.IsAttached()
      QueueDeleteOnProjectedCellReset()
   EndIf
EndEvent

Event OnActivate(ObjectReference akActionRef)
   Self.DisableNoWait()
   If !_bPickedUp
      _bPickedUp = True
      akActionRef.AddItem(Gold001, GetCoinCount(), True)
   EndIf
   Self.SetDestroyed() ; disable further pickup prompts in case we somehow become enabled again
   Self.Delete()
EndEvent

Event OnCellDetach()
   QueueDeleteOnProjectedCellReset()
EndEvent
Event OnDetachedFromCell()
   QueueDeleteOnProjectedCellReset()
EndEvent
Event OnCellAttach()
   Self.UnregisterForUpdateGameTime()
EndEvent
Event OnAttachedToCell()
   Self.UnregisterForUpdateGameTime()
EndEvent

Function QueueDeleteOnProjectedCellReset()
   Int      iHours    = Game.GetGameSettingInt("iHoursToRespawnCell")
   Location kLocation = Self.GetCurrentLocation()
   If kLocation && kLocation.IsCleared()
      iHours = Game.GetGameSettingInt("iHoursToRespawnCellCleared")
   EndIf
   RegisterForSingleUpdateGameTime(iHours)
EndFunction

Event OnUpdate()
   ;
   ; Our parent cell is expected to have reset; carry out a queued deletion.
   ;
   Self.DisableNoWait()
   Self.SetDestroyed() ; disable further pickup prompts in case we somehow become enabled again
   Self.Delete()
EndEvent
