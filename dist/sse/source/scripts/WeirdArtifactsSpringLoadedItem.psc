Scriptname WeirdArtifactsSpringLoadedItem extends ObjectReference

GlobalVariable Property WeirdArtifactsSpringLoadedWineMagSelf Auto

Event OnLoad()
   Self.ApplyHavokImpulse(0.0, 0.0, 1.0, WeirdArtifactsSpringLoadedWineMagSelf.GetValue())
EndEvent
