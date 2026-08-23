Scriptname WeirdArtifactsFriendFactionMainEffect extends ActiveMagicEffect

Faction Property pkTargetFaction Auto
{The faction we want the effect target to be ignored by.}

Faction Property pkFriendFaction Auto
{A "friend" faction created as part of this mod. It will be made a friend of the "target" faction, and the actor affected by this effect will be added to and removed from this "friend" faction.}

Actor _kTarget

Event OnEffectStart(Actor akTarget, Actor akCaster)
   _kTarget = akTarget

   pkFriendFaction.SetAlly(pkTargetFaction, True, True)
	_kTarget.AddToFaction(pkFriendFaction)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   _kTarget.RemoveFromFaction(pkFriendFaction)
EndEvent
