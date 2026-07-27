Scriptname WeirdArtifactsBoundCheeseWheelSCRIPT extends ObjectReference

Potion Property WeirdArtifactsBoundCheeseWheel Auto

Bool _bConsumed   = False
Bool _bDespawning = False
Bool _bDespawned  = False

Event OnEquipped(Actor akActor)
   _bConsumed = True
EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
   If akOldContainer
      If akNewContainer
         ;
         ; Container-to-container transfer. Can we erase it from the destination 
         ; container?
         ;
         akNewContainer.RemoveItem(WeirdArtifactsBoundCheeseWheel, 999999)
         Debug.Trace("[Weird Artifacts][Bound Cheese Wheel] Detected transfer to " + akNewContainer + "; removed all from that container.")
      ElseIf !_bConsumed
         ;
         ; Item dropped.
         ;
         SetDestroyed(True) ; disable picking up the cheese wheel during the "dispel" animation
         ;
         ; Play "dispel" animation; then disable and delete:
         ;
         _bDespawning = True
         If Is3DLoaded()
            Despawn()
         EndIf
         Return
      EndIf
   EndIf
   ;
   ; Else, item picked up from the world (PlaceAtMe'd?). Not sure if this fires when 
   ; the item is initially spawned in an inventory?
   ;
EndEvent

Event OnLoad()
   If !_bDespawning
      Return
   EndIf
   Despawn()
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
