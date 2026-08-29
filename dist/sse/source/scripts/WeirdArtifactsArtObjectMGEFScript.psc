Scriptname WeirdArtifactsArtObjectMGEFScript extends ActiveMagicEffect
{Use to attach a Visual Effect to the actor affected by an armor enchantment or other self-casted effect.}

VisualEffect Property pkEffect Auto

ActorBase Property pkPlayerFirstPersonSpecialCase = None Auto
{Use this if you want the effect to properly clip into scenery when attached to the player, even when seen in first-person view. It should be an empty-skeleton actor (e.g. dunMiddenEmptyRace).

Normally, Visual Effects attached to the player will render on top of all other objects while in first-person view. This setting works around that by spawning an ObjectReference and animating it toward the player whenever they're in first-person view.}

Actor _kTarget = None
Actor _kFirstPersonModel = None

Bool _bInFirstPerson = False

Event OnEffectStart(Actor akTarget, Actor akCaster)
   pkEffect.Play(akTarget)
	If pkPlayerFirstPersonSpecialCase && akTarget == Game.GetPlayer()
		_kTarget = akTarget
		_kFirstPersonModel = akTarget.PlaceAtMe(pkPlayerFirstPersonSpecialCase, 1, False, True) as Actor
		_kFirstPersonModel.SetAngle(0, 0, _kTarget.GetAngleZ())
		_kFirstPersonModel.SetVehicle(_kTarget)
		RegisterForSingleUpdate(0.1)
	EndIf
EndEvent

Event OnUpdate()
	If IsInFirstPerson()
		If !_bInFirstPerson
			_bInFirstPerson = True
			pkEffect.Stop(_kTarget)
			_kFirstPersonModel.EnableNoWait()
			pkEffect.Play(_kFirstPersonModel)
		EndIf
	Else
		If _bInFirstPerson
			_bInFirstPerson = False
			pkEffect.Play(_kTarget)
			pkEffect.Stop(_kFirstPersonModel)
			_kFirstPersonModel.DisableNoWait()
		EndIf
	EndIf
	RegisterForSingleUpdate(0.15)
EndEvent

Bool Function IsInFirstPerson()
	Return _kTarget.HasNode("Camera1st [Cam1]")
EndFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	UnregisterForUpdate()
	If !_bInFirstPerson
		pkEffect.Stop(akTarget)
	EndIf
	If _kFirstPersonModel
		_kFirstPersonModel.DisableNoWait()
		_kFirstPersonModel.Delete()
		_kFirstPersonModel = None
	EndIf
EndEvent
