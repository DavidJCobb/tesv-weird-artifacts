Scriptname WeirdArtifactsSpringLoadedEffect extends ActiveMagicEffect

GlobalVariable Property WeirdArtifactsSpringLoadedWineMagActor Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   akTarget.ForceRemoveRagdollFromWorld()
   Utility.Wait(0.10)
   akTarget.PushActorAway(akTarget, 15.0)
   RegisterForSingleUpdate(2.25)
EndEvent

Event OnUpdate()
   Actor kTarget = GetTargetActor()
   If !kTarget
      Return
   EndIf
   kTarget.ForceRemoveRagdollFromWorld()
   Self.Dispel()
EndEvent
