Scriptname WeirdArtifactsUtilDeleteOnDestroy extends ObjectReference

Int    Property piDeletePastStage Auto
Float  Property pfDeleteDelay = 0.0 Auto
String Property psGamebryoAnim = "" Auto

Bool _bQueuedForDelete = False

Event OnDestructionStageChanged(Int aiOldStage, Int aiCurrentStage)
   If _bQueuedForDelete
      Return
   EndIf
   If aiCurrentStage < piDeletePastStage
      Return
   EndIf
   _bQueuedForDelete = True
   If psGamebryoAnim
      PlayGamebryoAnimation(psGamebryoAnim, True)
   EndIf
   RegisterForSingleUpdate(pfDeleteDelay)
EndEvent

Event OnUpdate()
   If !_bQueuedForDelete
      Return
   EndIf
   DisableNoWait()
   Delete()
EndEvent

Event OnUnload()
   If !_bQueuedForDelete
      Return
   EndIf
   DisableNoWait()
   Delete()
EndEvent
