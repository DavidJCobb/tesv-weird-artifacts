Scriptname WeirdArtifactsArtObjectMGEFScript extends ActiveMagicEffect
{Use to attach a Visual Effect to the actor affected by an armor enchantment or other self-casted effect.}

VisualEffect Property pkEffect Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   pkEffect.Play(akTarget)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   pkEffect.Stop(akTarget)
EndEvent
