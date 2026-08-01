Scriptname WeirdArtifactsHealthbarEffectSCRIPT extends ActiveMagicEffect

VisualEffect Property WeirdArtifactsHealthbarRFCT Auto

Actor _kTarget
Bool  _bThrottle = False

Event OnEffectStart(Actor akTarget, Actor akCaster)
   _kTarget = akTarget
   WeirdArtifactsHealthbarRFCT.Play(_kTarget)
   
   Utility.Wait(0.05) ; give the health bar's 3D time to load
   _kTarget.SetSubGraphFloatVariable("fDampRate", 0.5) ; faster updates
   UpdateDisplayedValue()
   RegisterForSingleUpdate(0.75)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
   If _bThrottle
      Return
   EndIf
   _bThrottle = True
   UpdateDisplayedValue()
   RegisterForSingleUpdate(0.10)
EndEvent

Event OnUpdate()
   If _bThrottle
      _bThrottle = False
   Else
      ;
      ; When not throttling our responses to hit events, we poll to detect 
      ; NPC healing.
      ;
      UpdateDisplayedValue()
   EndIf
   RegisterForSingleUpdate(0.75)
EndEvent

Function UpdateDisplayedValue()
   If !_kTarget
      Return
   EndIf
   Float v = _kTarget.GetActorValuePercentage("Health")
   _kTarget.SetSubGraphFloatVariable("fToggleBlend", v)
EndFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   WeirdArtifactsHealthbarRFCT.Stop(akTarget)
EndEvent
