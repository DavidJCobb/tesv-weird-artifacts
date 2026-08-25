Scriptname WeirdArtifactsInvisFurniture extends ObjectReference

Actor _kTarget      = None
Bool  _bActivated   = False
Bool  _bTearingDown = False

Function SetDesiredActor(Actor akTarget)
	If _kTarget
		Return
	EndIf
	_kTarget = akTarget
	Debug.Trace("[Weird Artifacts][Invisible Furniture] Marker " + Self + " has set its target actor to " + _kTarget + ".")
	RegisterForSingleUpdate(5.00) ; failsafe: delete if 3D doesn't load or activation fails
	If Is3DLoaded()
		_TryActivate()
	Else
		EnableNoWait()
	EndIf
EndFunction

Function _TryActivate()
	If !Self.Activate(_kTarget)
		If _kTarget == Game.GetPlayer()
			Debug.Trace("[Weird Artifacts][Invisible Furniture] Marker " + Self + " can't be activated by the player. The marker's base form must have a non-zero-length name; the game is hardcoded not to let the player activate nameless refs, even via script.")
		Else
			Debug.Trace("[Weird Artifacts][Invisible Furniture] Marker " + Self + " can't be activated by " + _kTarget + ". Reason unknown.")
		EndIf
	EndIf
EndFunction

Event OnLoad()
	If _bActivated || !_kTarget
		Return
	EndIf
	_TryActivate()
EndEvent

Event OnActivate(ObjectReference akActionRef)
	Debug.Trace("[Weird Artifacts][Invisible Furniture] Marker " + Self + " activated by " + akActionRef + ".")
	If akActionRef == _kTarget
		_bActivated = True
		RegisterForSingleUpdate(1.00)
	EndIf
EndEvent

Event OnUpdate()
	If _bTearingDown
		Return
	EndIf
	If _bActivated && IsActorUsingMe()
		RegisterForSingleUpdate(0.25)
		Return
	EndIf
	BeginTeardown()
EndEvent

Function BeginTeardown()
	_bTearingDown = True
	Debug.Trace("[Weird Artifacts][Invisible Furniture] Tearing down: " + Self + ". (Ever activated? " + _bActivated + ".)")
	DisableNoWait()
	Delete()
EndFunction

Bool Function IsActorUsingMe()
	If !Self.IsFurnitureInUse() || !Self.Is3DLoaded()
		Return False
	EndIf
	If _kTarget.GetSitState() == 0 && _kTarget.GetSleepState() == 0
		Return False
	EndIf
	Return True
EndFunction

; Failsafes in case the actor is unable to activate the furniture for whatever reason.
; Don't want to leave the furniture lying around forever.
Event OnCellDetach()
	Debug.Trace("[Weird Artifacts][Invisible Furniture] Cell detached: " + Self)
	BeginTeardown()
EndEvent
Event OnDetachedFromCell()
	Debug.Trace("[Weird Artifacts][Invisible Furniture] Moved to detached cell: " + Self)
	BeginTeardown()
EndEvent
