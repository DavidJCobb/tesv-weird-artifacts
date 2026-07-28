Scriptname WeirdArtifactsUtilPlaceLVLI extends ObjectReference

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
   EndIf
   Self.DisableNoWait()
   Self.Delete()
EndEvent
