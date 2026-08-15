Scriptname WeirdArtifactsInvertedLockpickSCRIPT extends ObjectReference

Actor Property PlayerRef Auto
Perk  Property WeirdArtifactsInvertedLockpickPerk Auto

Event OnEquipped(Actor akActor)
	If akActor == PlayerRef
		PlayerRef.AddPerk(WeirdArtifactsInvertedLockpickPerk)
	EndIf
EndEvent

Event OnUnequipped(Actor akActor)
	If akActor == PlayerRef
		PlayerRef.RemovePerk(WeirdArtifactsInvertedLockpickPerk)
	EndIf
EndEvent
