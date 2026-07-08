Scriptname WeirdArtifactsGoldspillerEffect extends ActiveMagicEffect

MiscObject Property pkCurrencyItem Auto
Int Property piMaxDrops = 50 Auto

Actor _kTarget
Int   _iDropsRemaining  = 0
Float _fYawPerDrop      = 0.0
Float _fYawCurrent      = 0.0
Int   _iAsyncCallStacks = 0 ; not including OnUpdate
Bool  _bUpdateQueued    = False

;/
   This script makes the target actor drop gold coins one at a time (rather than 
   dropping a single stacked coin ref). It also applies a weak Havok impulse to 
   the dropped coins to scatter them all in different directions.
   
   `DropObject` and `ApplyHavokImpulse` are both latent functions: they queue a 
   task to run on the game's main thread, and they suspend the Papyrus call stack 
   that invoked them until that task runs to completion. This is bad for us: it 
   means there'll be heavy delays per coin. Fortunately, there's a simple enough 
   workaround: have multiple Papyrus call stacks trigger coin drops, so we can 
   stuff more tasks onto the main thread at a time.
   
   Papyrus doesn't have any APIs for spawning arbitrary call stacks, i.e. there 
   is no function akin to `fork`. However, `OnUpdate` is a second call stack 
   that we can queue to run basically for free. Additionally, we can (ab)use the 
   `OnItemRemoved` event as a source for additional call stacks: each item we 
   successfully drop gives us the chance to queue another item drop.
   
   Our main stack will be the `OnEffectStart` stack. `OnUpdate` will be queued 
   exclusively from the main stack; since we can only queue one update at a time, 
   and re-queueing just reschedules a pending update, we'll need a bool to know 
   whether we already have an update queued. For `OnItemRemoved`, we'll need an 
   inventory event filter (in case the target is disarmed or otherwise drops an 
   unrelated item) and a counter (to constrain the number of additional stacks; 
   otherwise I think we risk the number of stacks growing exponentially, since 
   each drop effectively triggers [the queueing of] yet more drops).
/;

Event OnEffectStart(Actor akTarget, Actor akCaster)
   akTarget = _kTarget
   
   _iDropsRemaining = akTarget.GetItemCount(pkCurrencyItem)
   If _iDropsRemaining <= 0
      Self.Dispel()
      Return
   EndIf
   If _iDropsRemaining > piMaxDrops
      _iDropsRemaining = piMaxDrops
   EndIf
   
   _fYawPerDrop = 6.283185307 / _iDropsRemaining ; 2pi / count to drop
   
   Self.AddInventoryEventFilter(pkCurrencyItem)
   
   ; Setup done; now we start droppin'.
   While _iDropsRemaining > 0
      If !_bUpdateQueued && _iDropsRemaining > 1
         _bUpdateQueued = True
         RegisterForSingleUpdate(0.001)
      EndIf
      ExecuteSingleDrop()
   EndWhile
EndEvent

Event OnUpdate()
   _bUpdateQueued = False
   ExecuteSingleDrop()
EndEvent

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
   If _iAsyncCallStacks >= 7
      Return
   EndIf
   _iAsyncCallStacks = _iAsyncCallStacks + 1
   ExecuteSingleDrop()
   If _iDropsRemaining <= 0
      Self.Dispel()
   EndIf
   _iAsyncCallStacks = _iAsyncCallStacks - 1
EndEvent

Function ExecuteSingleDrop()
   If _iDropsRemaining <= 0
      Return
   EndIf
   _iDropsRemaining = _iDropsRemaining - 1
   ObjectReference kDropped = _kTarget.DropObject(pkCurrencyItem, 1)
   If kDropped
      If kDropped.Is3DLoaded()
         kDropped.ApplyHavokImpulse( \
            Math.cos(_fYawCurrent),  \
            Math.sin(_fYawCurrent),  \
            0.2,                     \
            3.0                      \
         )
      Endif
   Else
      ;
      ; No item ref. Did the target run out of gold early (e.g. because 
      ; something else removed some)?
      ;
      If _kTarget.GetItemCount(pkCurrencyItem) <= 0
         Self.Dispel()
         Return
      EndIf
   EndIf
   _fYawCurrent = _fYawCurrent + _fYawPerDrop
   If _iDropsRemaining < 0
      Self.Dispel()
   EndIf
EndFunction
