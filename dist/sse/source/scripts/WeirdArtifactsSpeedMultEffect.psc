Scriptname WeirdArtifactsSpeedMultEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.ModActorValue("CarryWeight", 0.01)
	akTarget.ModActorValue("CarryWeight", -0.01)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.ModActorValue("CarryWeight", 0.01)
	akTarget.ModActorValue("CarryWeight", -0.01)
EndEvent
