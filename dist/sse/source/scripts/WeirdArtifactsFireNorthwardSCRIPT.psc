Scriptname WeirdArtifactsFireNorthwardSCRIPT extends ObjectReference

; config
Spell Property pkSpell Auto

; state
Actor Property pkCause Auto

; forms
Static Property NorthMarker Auto
Static Property XMarker Auto

Bool _fired = False

Float Function GetNorthAngle()
	Float fZAngle = 0.0
	If Self.IsInInterior()
		ObjectReference kNorthMarker = Game.FindClosestReferenceOfType(NorthMarker, 0.0, 0.0, 0.0, 50000.0)
		If kNorthMarker
			;
			; If no NorthMarker, then north is +Y.
			;
			fZAngle = kNorthMarker.GetAngleZ()
		EndIf
	EndIf
	;
	; The game treats an angle of 0 as "north." Trigonometry, however, treats an angle of 
	; 0 as "east."
	;
	If fZAngle < 90.0
		Return 90.0 - fZAngle
	Else
		Return 450.0 - fZAngle
	EndIf
EndFunction

Event OnInit()
	RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
	If _fired
		Return
	EndIf
	_fired = true
	
	Float fNorthAngle = GetNorthAngle()
	
	Float fX = Self.GetPositionX()
	Float fY = Self.GetPositionY()
	Float fZ = Self.GetPositionZ()
	
	fX += Math.cos(fNorthAngle) * 512
	fY += Math.sin(fNorthAngle) * 512
	
	ObjectReference kMarker = Self.PlaceAtMe(XMarker, 1, False, False)
	kMarker.SetAngle(0, 0, 0)
	kMarker.SetPosition(fX, fY, fZ)
	
	pkSpell.RemoteCast(Self, pkCause, kMarker)
	kMarker.DisableNoWait()
	kMarker.Delete()
	Self.DisableNoWait()
	Self.Delete()
EndEvent
