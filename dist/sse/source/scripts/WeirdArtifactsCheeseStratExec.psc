Scriptname WeirdArtifactsCheeseStratExec extends ActiveMagicEffect

Potion Property WeirdArtifactsBoundCheeseWheel Auto

Spell Property WeirdArtifactsCheeseStrategistHelmRevokeSpell Auto

Actor _kTarget

Event OnEffectStart(Actor akTarget, Actor akCaster)
   _kTarget = akTarget

   Float health = akTarget.GetActorValue("Health")
   Float max    = health / akTarget.GetActorValuePercentage("Health")
   Float lost   = max - health
   
   Float health_restored_per_wheel = 15
   
   Int item_count = Math.Ceiling((max - health) / health_restored_per_wheel)
   Int item_min   = Math.Ceiling(akTarget.GetActorValue("CarryWeight"))
   If item_count > 0
      if item_count < item_min
         item_count = item_min
      EndIf
      akTarget.AddItem(WeirdArtifactsBoundCheeseWheel, item_count)
      akTarget.DoCombatSpellApply(WeirdArtifactsCheeseStrategistHelmRevokeSpell, akTarget)
      Debug.Trace("[Weird Artifacts][Cheese Strategist's Helm] " + item_count + " cheese wheels added to " + _kTarget + ".")
   EndIf
EndEvent

Event OnDying(Actor akKiller)
   _kTarget.RemoveItem(WeirdArtifactsBoundCheeseWheel, 999999)
   Debug.Trace("[Weird Artifacts][Cheese Strategist's Helm] Cheese wheels revoked from " + _kTarget + " on death.")
EndEvent
