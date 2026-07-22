Scriptname WeirdArtifactsBoundCheeseWheelSCRIPT extends ObjectReference

Bool _bDespawning = False
Bool _bDespawned  = False

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
   If akOldContainer && !akNewContainer
      SetDestroyed(True) ; disable picking up the cheese wheel during the "dispel" animation
      ;
      ; Play "dispel" animation; then disable and delete:
      ;
      _bDespawning = True
      If Is3DLoaded()
         Despawn()
      EndIf
   EndIf
EndEvent

Event OnLoad()
   If !_bDespawning
      Return
   EndIf
   PlayAnimation("EndAnim")
   Utility.Wait(3.0)
   DisableNoWait()
   Delete()
EndEvent

Function Despawn()
   If _bDespawned
      Return
   EndIf
   _bDespawned = True
   PlayAnimation("EndAnim")
   Utility.Wait(3.0)
   DisableNoWait()
   Delete()
EndFunction
