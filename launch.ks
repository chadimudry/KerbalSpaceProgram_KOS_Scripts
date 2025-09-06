// ________________________________________________ //
//                                                  //
//    Ascent Program V0                             //
// ________________________________________________ //
// Infos    : Permet d'envoyer une fusée en orbite  //
//            donnant une altitude et un cap cible. //
// Version  : V0                                    //
// ------------------------------------------------ //

// import librairies
runpath("0:/kOS_Tools/Tool_Countdown.ks").

clearScreen.
sas off.
rcs off.

lock throttle to 1.
lock steering to heading(90, 90). // °
// heading(direction, pitch)
// East = 90° ; North = 0° ; South° = 180° ; West = 270°

print("Start countdown ...") at (0, 0).
countdown(5).
stage.
print("Lift off!").