Scriptname WeirdArtifactsUtilPlaceLVLI extends ObjectReference

Bool        Property pbDebugLog = False Auto
LeveledItem Property pkFormToPlace Auto
Bool        Property pbResetRotation = False Auto
Float[]     Property pfPositionOffset Auto

Event OnInit()
   If pkFormToPlace
      ObjectReference placed = Self.PlaceAtMe(pkFormToPlace, 1, False, True)
      If pfPositionOffset.Length >= 3
         placed.MoveTo(Self, pfPositionOffset[0], pfPositionOffset[1], pfPositionOffset[2], False)
      EndIf
      If pbResetRotation
         placed.SetAngle(0, 0, 0)
      EndIf
      placed.EnableNoWait()
      If pbDebugLog
         Debug.Trace("[Weird Artifacts][Place LVLI] " + Self + " placed " + placed + ".")
      EndIf
   EndIf
   Self.DisableNoWait()
   Self.Delete()
   If pbDebugLog
      Debug.Trace("[Weird Artifacts][Place LVLI] " + Self + " is self-deleting.")
   EndIf
EndEvent
