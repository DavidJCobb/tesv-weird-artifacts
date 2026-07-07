Scriptname WeirdArtifactsSpringLoadedEffect extends ActiveMagicEffect

GlobalVariable Property WeirdArtifactsSpringLoadedWineMagActor Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   ; Stop ragdoll...
   ;akTarget.ForceRemoveRagdollFromWorld()
   ;Utility.Wait(0.10)
   
   ; When a ref pushes itself, it seems like the force vector ends up being 
   ; its local up-vector. For actors who aren't ragdolling, this will always 
   ; be world-up (which is why we stop ragdolling earlier: to avoid getting 
   ; too skewed a launch).
   akTarget.PushActorAway(akTarget, WeirdArtifactsSpringLoadedWineMagActor.GetValue())
EndEvent
