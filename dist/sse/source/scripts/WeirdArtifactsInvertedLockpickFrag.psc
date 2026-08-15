Scriptname WeirdArtifactsInvertedLockpickFrag extends Perk

Actor Property PlayerRef Auto

Function Exec(ObjectReference akTriggerRef, Actor akActor)
   If akActor != PlayerRef
	  Return
   EndIf
	Form kBase = akTriggerRef.GetBaseObject()
	if (kBase as Container) || (kBase as Door)
		akTriggerRef.Lock(True, False)
	EndIf
EndFunction
