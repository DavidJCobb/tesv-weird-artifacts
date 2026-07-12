Scriptname WeirdArtifactsGoldspillEffect extends ActiveMagicEffect

Activator  Property pkCoinGroupBaseForm Auto
MiscObject Property pkCurrencyItem Auto

WeirdArtifactsGoldspillManagerSCRIPT Property WeirdArtifactsGoldspillManager Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   Int iGoldCount     = akTarget.GetItemCount(pkCurrencyItem)
   Int iCoinsPerGroup = WeirdArtifactsGoldspillCoinGroup.GetCoinCount()
   If iGoldCount < iCoinsPerGroup
      ;
      ; Target doesn't have enough coins to spill.
      ;
      Self.Dispel()
      Return
   EndIf
   
   Int iSpillable = WeirdArtifactsGoldspillManager.GetRemainingSpillBudget()
   If iSpillable <= 0
      ;
      ; Too many coin groups in the loaded area.
      ;
      Self.Dispel()
      Return
   EndIf
   
   Int iGroups = iGoldCount / iCoinsPerGroup
   If iGroups > iSpillable
      iGroups = iSpillable
   EndIf
   If iGroups > 3
      iGroups = 3
   EndIf
   
   ObjectReference[] kGroupRefs = new ObjectReference[3]
   
   Int i = 0
   While i < iGroups
      ObjectReference kGroup = akTarget.PlaceAtMe(pkCoinGroupBaseForm, iGroups, False, True)
      akTarget.RemoveItem(pkCurrencyItem, iGroups * iCoinsPerGroup, True)
      WeirdArtifactsGoldspillManager.OnGoldSpilled(1)
      ;
      ; PlaceAtMe spawns the coin groups at the victim's feet, so they may appear 
      ; underground. We need to remedy this.
      ;
      kGroupRefs[i] = kGroup
      kGroup.MoveTo(akTarget, 0, 0, 128, False)
      kGroup.SetAngle(0, 0, 0)
      ;
      i += 1
   EndWhile
   ;
   ; Enable the groups all at once, so the effect appears less laggy:
   ;
   i = 0
   While i < iGroups
      ObjectReference kGroup = kGroupRefs[i]
      If kGroup
         kGroup.EnableNoWait()
      Else
         i = iGroups ; Break
      EndIf
      ;
      i += 1
   EndWhile
EndEvent
