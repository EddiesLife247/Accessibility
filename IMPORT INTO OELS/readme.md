CONFIG FILE:
The config contains new slower lighting settings that are easier on eyes chases, and while on scene. (We use leds and leds3 mostly)
250 (slow lighting left/right pattern)
1200 (slow on sceen pattern)


client/controller_lights.lua
this turns off wigwags, and envrionemntal lighting when lights are on.
this also turns off the emergency lighting (flashing break lights for all emergency vehicles. (NON ELS WILL NOT WORK)
if you need this comment out the line:                 SetVehicleHasMutedSirens(veh, true)
