Scriptname WeirdArtifactsSpringLoadedEffect extends ActiveMagicEffect

GlobalVariable Property WeirdArtifactsSpringLoadedWineMagActor Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   akTarget.PushActorAway(akTarget, 0.0)
   akTarget.ApplyHavokImpulse(0.0, 0.0, 1.0, WeirdArtifactsSpringLoadedWineMagActor.GetValue())
EndEvent
