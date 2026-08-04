Scriptname WeirdArtifactsSpringLoadedEffect extends ActiveMagicEffect

Activator Property dummyObject Auto
GlobalVariable Property WeirdArtifactsSpringLoadedWineMagActor Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   ;
   ; When a ref pushes itself, it seems like the force vector ends up being 
   ; its local up-vector. For actors who aren't ragdolling, this will always 
   ; be world-up. One might think, then, that we can just have the target 
   ; push themselves away, and you're right: that *should* work.
   ;
   ; However, if the player is in first-person when they drink the wine, 
   ; they won't launch as far as they're supposed to. I have tried every 
   ; possible workaround and none of them have worked.
   ;
   If akTarget.GetAnimationVariableInt("i1stPerson") != 0 ; in first-person?
      akTarget.ForceAddRagdollToWorld()
      akTarget.ForceAddRagdollToWorld()
      akTarget.ForceAddRagdollToWorld()
   EndIf
   akTarget.PushActorAway(akTarget, WeirdArtifactsSpringLoadedWineMagActor.GetValue())
EndEvent
