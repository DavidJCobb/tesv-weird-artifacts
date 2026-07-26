Scriptname WeirdArtifactsCheeseStratTrigger extends ActiveMagicEffect

Spell Property WeirdArtifactsCheeseStrategistHelmExecSpell Auto

Bool _bThrottle = False

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
   If _bThrottle
      Return
   EndIf
   Actor target = GetTargetActor()
   Float perc   = target.GetActorValuePercentage("Health")
   If perc < 0.3
      _bThrottle = True
      target.DoCombatSpellApply(WeirdArtifactsCheeseStrategistHelmExecSpell, target)
      RegisterForSingleUpdate(5.0)
   EndIf
EndEvent

Event OnUpdate()
   _bThrottle = False
EndEvent
