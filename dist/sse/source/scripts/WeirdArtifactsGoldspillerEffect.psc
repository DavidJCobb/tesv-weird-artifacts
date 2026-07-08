Scriptname WeirdArtifactsGoldspillerEffect extends ActiveMagicEffect

MiscObject Property pkCurrencyItem Auto
Int Property piMaxDrops = 50 Auto

Actor _kTarget
Int   _iDropsRemaining  = 0
Float _fYawPerDrop      = 0.0
Float _fYawCurrent      = 0.0

;/
   This script makes the target actor drop gold coins one at a time (rather than 
   dropping a single stacked coin ref). It also applies a weak Havok impulse to 
   the dropped coins to scatter them all in different directions.
/;

Event OnEffectStart(Actor akTarget, Actor akCaster)
   _kTarget = akTarget
   
   _iDropsRemaining = akTarget.GetItemCount(pkCurrencyItem)
   If _iDropsRemaining <= 0
      Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " has no gold to spill; dispelling.")
      Self.Dispel()
      Return
   EndIf
   If _iDropsRemaining > piMaxDrops
      _iDropsRemaining = piMaxDrops
   EndIf
   
   _fYawPerDrop = 6.283185307 / _iDropsRemaining ; 2pi / count to drop
   
   Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " is about to start dropping gold...")
   ; Setup done; now we start droppin'.
   While _iDropsRemaining > 0
      ExecuteSingleDrop()
   EndWhile
   Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " has finished dropping gold; main stack terminating...")
EndEvent

Function ExecuteSingleDrop()
   If _iDropsRemaining <= 0
      ;Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " is already out of gold; cancelling single drop.")
      Return
   EndIf
   
   ObjectReference[] kDrops = new ObjectReference[3]
   
   ObjectReference kFirstDrop
   Int iCurrentDrop    = 0
   Int iAttemptedDrops = 0
   Int iSuccessDrops   = 0
   While iCurrentDrop < kDrops.Length && _iDropsRemaining > 0
      _iDropsRemaining = _iDropsRemaining - 1
      ObjectReference kDrop = _kTarget.DropObject(pkCurrencyItem, 1)
      iAttemptedDrops = iAttemptedDrops + 1
      If kDrop
         kDrops[iCurrentDrop] = kDrop
         iSuccessDrops = iSuccessDrops + 1
         If !kFirstDrop
            kFirstDrop = kDrop
         EndIf
      EndIf
      iCurrentDrop = iCurrentDrop + 1
   Endwhile
   
   If !kFirstDrop || iSuccessDrops < iAttemptedDrops
      ;
      ; Did the target run out of gold early (e.g. because something 
      ; else removed some)?
      ;
      If _kTarget.GetItemCount(pkCurrencyItem) <= 0
         Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " ran out of gold early; dispelling.")
         Self.Dispel()
      EndIf
   Else
      Bool b3DLoaded = True
      If !kFirstDrop.Is3DLoaded()
         Utility.Wait(0.05)
         If !kFirstDrop.Is3DLoaded()
            Utility.Wait(0.10)
            If !kFirstDrop.Is3DLoaded()
               b3DLoaded = False
            EndIf
         EndIf
      EndIf
      If b3DLoaded
         iCurrentDrop = 0
         While iCurrentDrop < kDrops.Length
            ObjectReference kCurrentDrop = kDrops[iCurrentDrop]
            If kCurrentDrop && kCurrentDrop.Is3DLoaded()
               kCurrentDrop.ApplyHavokImpulse( \
                  Math.cos(_fYawCurrent),      \
                  Math.sin(_fYawCurrent),      \
                  0.2,                         \
                  3.0                          \
               )
               _fYawCurrent = _fYawCurrent + _fYawPerDrop
            EndIf
            iCurrentDrop = iCurrentDrop + 1
         EndWhile
      EndIf
   EndIf
   
   If _iDropsRemaining < 0
      ;Debug.Trace("[Weird Artifacts][Goldspiller] " + _kTarget + " has dropped as much gold as we wanted them to; dispelling.")
      Self.Dispel()
   EndIf
EndFunction
