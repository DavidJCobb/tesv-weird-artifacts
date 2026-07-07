Scriptname WeirdArtifactsSpringLoadedItem extends ObjectReference

GlobalVariable Property WeirdArtifactsSpringLoadedWineMagSelf Auto

Event OnLoad()
   Self.RegisterForSingleUpdate(0.25)
EndEvent

Event OnUpdate()
   If Self.Is3DLoaded()
      Self.ApplyHavokImpulse(0.0, 0.0, 1.0, WeirdArtifactsSpringLoadedWineMagSelf.GetValue())
   EndIf
EndEvent
