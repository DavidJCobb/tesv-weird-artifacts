Scriptname WeirdArtifactsEffectRainDanceTrigger extends ActiveMagicEffect

;/
   This effect is conditioned to be active when the boots' wearer is 
   in combat and isn't in an interior cell. We check whether we should 
   trigger rainy weather (based on the wearer's current location, etc.) 
   and if so, we have the wearer cast a spell on themselves.
   
   That spell is responsible for the weather change. We separate it out 
   so that we can give it a duration and flag it as No Recast, which 
   should result in it having a cooldown.
/;

FormList Property pkExcludedSpacesList Auto
Spell Property pkRainTriggerSpell Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   If IsInExcludedSpace(akTarget)
      Return
   EndIf
   akTarget.DoCombatSpellApply(pkRainTriggerSpell, akTarget)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
EndEvent

Bool Function IsInExcludedSpace(Actor akSubject)
   Cell       kParentCell
   Worldspace kParentWorld
   
   Int iSize    = pkExcludedSpacesList.GetSize()
   Int iCurrent = 0
   While iCurrent < iSize
      Form       kCurrent     = pkExcludedSpacesList.GetAt(iCurrent)
      Cell       kCurrentCell = kCurrent as Cell
      Worldspace kCurrentWorld
      If kCurrentCell
         If !kParentCell
            kParentCell = akSubject.GetParentCell()
         EndIf
         If kCurrentCell == kParentCell
            Return True
         EndIf
      Else
         kCurrentWorld = kCurrent as Worldspace
         If kCurrentWorld
            If !kParentWorld
               kParentWorld = akSubject.GetWorldspace()
            EndIf
            If kCurrentWorld == kParentWorld
               Return True
            EndIf
         EndIf
      EndIf
      iCurrent = iCurrent + 1
   EndWhile
   Return False
EndFunction

