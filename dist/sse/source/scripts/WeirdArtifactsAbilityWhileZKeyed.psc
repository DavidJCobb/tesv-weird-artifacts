Scriptname WeirdArtifactsAbilityWhileZKeyed extends ObjectReference

Actor Property PlayerRef Auto
Spell Property pkSpell Auto

Event OnGrab()
	PlayerRef.AddSpell(pkSpell, False)
EndEvent

Event OnRelease()
	Teardown()
EndEvent

; Failsafe events, just in case:
Event OnCellDetach()
	Teardown()
EndEvent
Event OnUnload()
	Teardown()
EndEvent
Event OnReset()
	Teardown()
EndEvent
Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	Teardown()
EndEvent

Function Teardown()
	PlayerRef.RemoveSpell(pkSpell)
EndFunction
