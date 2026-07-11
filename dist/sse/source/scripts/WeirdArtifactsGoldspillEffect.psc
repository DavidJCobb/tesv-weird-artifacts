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
   akTarget.PlaceAtMe(pkCoinGroupBaseForm, iGroups, False, False)
   akTarget.RemoveItem(pkCurrencyItem, iGroups * iCoinsPerGroup, True)
   WeirdArtifactsGoldspillManager.OnGoldSpilled(iGroups)
EndEvent
