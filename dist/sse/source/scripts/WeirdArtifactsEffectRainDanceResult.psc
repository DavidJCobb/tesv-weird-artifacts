Scriptname WeirdArtifactsEffectRainDanceResult extends ActiveMagicEffect

GlobalVariable Property WeirdArtifactsRainDanceWeatherDuration Auto

Weather Property pkRainyWeather Auto
{Fallback weather, if the current region has no rainy weather.}

Weather current_rainy_weather

Event OnEffectStart(Actor akTarget, Actor akCaster)
   Debug.Trace("[Weird Artifacts][Boots of the Rain Dancer] Weather effect starting...")
   
   current_rainy_weather = Weather.FindWeather(2)
   If !current_rainy_weather
      Debug.Trace("[Weird Artifacts][Boots of the Rain Dancer] No rainy weather in current region; using fallback weather...")
      current_rainy_weather = pkRainyWeather
   EndIf
   current_rainy_weather.SetActive(True, True)
   
   ;
   ; Limit the duration of the weather override to a few minutes. 
   ; (The duration of the effect itself controls how often the 
   ; wearer can activate it.)
   ;
   RegisterForSingleUpdate(WeirdArtifactsRainDanceWeatherDuration.GetValue())
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
   Debug.Trace("[Weird Artifacts][Boots of the Rain Dancer] Weather effect finishing.")
   StopRain()
EndEvent

Event OnUpdate()
   Debug.Trace("[Weird Artifacts][Boots of the Rain Dancer] Duration elapsed.")
   StopRain()
   Self.Dispel()
EndEvent

Function StopRain()
   If Weather.GetCurrentWeather() == current_rainy_weather
      Debug.Trace("[Weird Artifacts][Boots of the Rain Dancer] Weather is still active; releasing override.")
      Weather.ReleaseOverride()
   EndIf
EndFunction
