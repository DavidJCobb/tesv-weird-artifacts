Scriptname WeirdArtifactsBlindnessCombatEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;
	; Try to make the actor forget they saw their combat target, so we can 
	; reset their detection of said target.
	;
   Actor kCombatTarget = akTarget.GetCombatTarget()
	If kCombatTarget
		akTarget.StopCombat()
		;
		; Then, put them back in combat, but with reset detection, so they 
		; have to search for the target.
		;
		akTarget.StartCombat(kCombatTarget)
	EndIf
EndEvent