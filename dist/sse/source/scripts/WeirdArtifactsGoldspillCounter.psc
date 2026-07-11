Scriptname WeirdArtifactsGoldspillCounter extends ObjectReference

Actor Property PlayerRef Auto

Activator Property pkBaseFormToCount Auto

WeirdArtifactsGoldspillManagerSCRIPT Property WeirdArtifactsGoldspillManager Auto

;/
   Script to be attached to a trigger volume, intended to count how many Goldspill 
   coin-group refs are in the loaded area. When active, the trigger volume will be 
   kept anchored to the player, and it will use `OnTriggerEnter`/`OnTriggerLeave` 
   events to count how many coin-groups it contains.
   
   This is harder than it sounds due to some edge-cases with trigger volumes:
   
    - The trigger must be translated rather than moved whenever possible, as moving 
      the trigger will cause its 3D to unload, resulting in jank.
   
    - When a trigger's 3D unloads, the trigger will fire spurious "leave" events 
      for all detected refs. However, when the 3D reloads, it may not fire the 
      matching "enter" events for those refs. Fortunately, translating the trigger 
      can cause any undetected refs to then fire their "enter" events.
      
    - When a detected ref's 3D unloads, the trigger will fire a spurious "leave" 
      event for the ref.
      
    - When the player transitions into a new space (i.e. a different world or 
      interior cell), all refs in the space they're departing will unload 3D. This 
      will cause all detected refs to generate "leave" events for the trigger. It 
      appears that these are queued before `OnCellDetach` is queued, but I suspect 
      there'd be no defined ordering between `OnTriggerLeave` and `OnCellDetach` 
      anyway if enough events are queued (as some call stacks would be suspended, 
      and I don't know that they'd be resumed in any well-defined order).
      
      The effect of this is that if the trigger is detecting N refs and the player 
      transitions into a new space, the trigger will be bombarded with N calls to 
      `OnTriggerLeave`, and there is nothing you can do about it.
/;

Bool _bSyncToPlayer = False
Int  _iObjectCount  = 0

Bool Function IsMonitoring()
   Return _bSyncToPlayer
EndFunction
Function StartMonitoring()
   If _bSyncToPlayer
      Return
   EndIf
   _bSyncToPlayer = True
   Self.MoveTo(PlayerRef)
   Self.RegisterForSingleUpdate(3.0)
   WeirdArtifactsGoldspillManager.OnMonitoringStarted()
EndFunction
Function StopMonitoring()
   _bSyncToPlayer = False
   Self.UnregisterForUpdate()
   Self.MoveToMyEditorLocation()
EndFunction

Int Function Count()
   Return _iObjectCount
EndFunction

Event OnUpdate()
   If !_bSyncToPlayer
      Return
   EndIf
   
   If Self.Is3DLoaded() && IsInSameSpaceAsPlayer()
      Self.TranslateToRef(PlayerRef, 99999.0, 0)
   Else
      Self.MoveTo(PlayerRef)
   EndIf
   
   If _bSyncToPlayer ; check in case it changed while calling latent functions above
      Self.RegisterForSingleUpdate(3.0)
   EndIf
EndEvent

Event OnTriggerEnter(ObjectReference akSubject)
   If akSubject.GetBaseObject() == pkBaseFormToCount
      _iObjectCount += 1
   EndIf
EndEvent

Event OnTriggerLeave(ObjectReference akSubject)
   If akSubject.GetBaseObject() == pkBaseFormToCount
      _iObjectCount -= 1
   EndIf
EndEvent

Bool Function IsInSameSpaceAsPlayer()
   Worldspace kThisWorldspace = Self.GetWorldspace()
   Worldspace kNextWorldspace = PlayerRef.GetWorldspace()
   If kThisWorldspace != kNextWorldspace
      Return False
   EndIf
   If !kThisWorldspace
      ;
      ; In an interior cell.
      ;
      Cell kThisCell = Self.GetParentCell()
      Cell kNextCell = PlayerRef.GetParentCell()
      If kThisCell != kNextCell
         Return False
      EndIf
   EndIf
   Return True
EndFunction
