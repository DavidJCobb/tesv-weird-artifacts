Scriptname WeirdArtifactsCheeseStratRevoke extends ActiveMagicEffect

Potion Property WeirdArtifactsBoundCheeseWheel Auto

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   akTarget.RemoveItem(WeirdArtifactsBoundCheeseWheel, 999999)
   Debug.Trace("[Weird Artifacts][Cheese Strategist's Helm] Cheese wheels revoked from " + akTarget + " after time threshold.")
EndEvent
