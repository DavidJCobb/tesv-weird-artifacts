Scriptname WeirdArtifactsStopCombatEffect extends ActiveMagicEffect

Faction Property pkIfPursuingFaction = None Auto
{Only stop combat if the effect target has a Combat Target that is in this faction.}

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If pkIfPursuingFaction
		Actor _kCombatTarget = akTarget.GetCombatTarget()
		If !_kCombatTarget || !_kCombatTarget.IsInFaction(pkIfPursuingFaction)
			Dispel()
			Return
		EndIf
	EndIf
	akTarget.StopCombat()
	Dispel()
EndEvent
