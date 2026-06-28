Scriptname WeirdArtifactsEffectRainDanceResult extends ActiveMagicEffect

Weather Property pkRainyWeather Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
   pkRainyWeather.SetActive(True, True)
   ;
   ; Limit the duration of the weather override to a few minutes. 
   ; (The duration of the effect itself controls how often the 
   ; wearer can activate it; it should be longer than this here 
   ; duration, so you can't have back-to-back rains.)
   ;
   RegisterForSingleUpdate(290) ; 6min
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   StopRain()
EndEvent

Event OnUpdate()
   StopRain()
EndEvent

Function StopRain()
   If Weather.GetCurrentWeather() == pkRainyWeather
      Weather.ReleaseOverride()
   EndIf
EndFunction
