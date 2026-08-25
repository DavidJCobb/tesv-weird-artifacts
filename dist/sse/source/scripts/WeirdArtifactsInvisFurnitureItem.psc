Scriptname WeirdArtifactsInvisFurnitureItem extends ObjectReference

Message Property WeirdArtifactsCannotUseInvisFurnitureMessage Auto

Bool Property pbFurnitureIsSit = True Auto
{Set this to False if the furniture uses "sleep" markers instead of "sit" markers.}

Furniture Property pkFurniture Auto
{The invisible furniture to spawn. Must have the "WeirdArtifactsInvisFurniture" script attached. The base form must have a name (all-whitespace is fine).}

Message Property pkAlreadyUsingMessage = None Auto
{A special-case message to be shown if the player is already using this invisible furniture type.}

Event OnEquipped(Actor akActor)
	If akActor.GetSitState() != 0 || akActor.GetSleepState() != 0
		;
		; Actor is already using a furniture. (NOTE: I'm not sure this would 
		; reliably detect "lean" furniture types.)
		;
		If akActor == Game.GetPlayer()
			;
			; If the player is using the item, show the appropriate "you can't do 
			; that" message.
			;
			Bool bShown = False
			If pkAlreadyUsingMessage
				;
				; We have a special message to be used if the player is already 
				; using the specific furniture that this item is configured for.
				;
				; Papyrus doesn't have APIs that allow us to get the furniture ref 
				; an actor is using, nor the actor using a particular marker on a 
				; furniture ref. We'll guesstimate whether the player is using our 
				; furniture type by just checking if there's one very near to the 
				; player.
				;
				ObjectReference kFurniture = Game.FindClosestReferenceOfTypeFromRef(pkFurniture, akActor, 64.0)
				If kFurniture
					pkAlreadyUsingMessage.Show()
					bShown = True
				EndIf
			EndIf
			If !bShown
				WeirdArtifactsCannotUseInvisFurnitureMessage.Show() ; generic message
			EndIf
		EndIf
		Return
	EndIf
	WeirdArtifactsInvisFurniture kMarker = akActor.PlaceAtMe(pkFurniture, 1, False, True) as WeirdArtifactsInvisFurniture
	kMarker.SetAngle(0, 0, akActor.GetAngleZ())
	kMarker.SetDesiredActor(akActor)
EndEvent
