// ________________________________________________ //
//                                                  //
//    Pitch Program V0                              //
// ________________________________________________ //
// Infos    : Compute the tilt of the vessel        //
//            function of the altitude.             //
// Version  : V0                                    //
// ------------------------------------------------ //

global function pitch_program {
    parameter switch_altitude is 250. // m
    set pitch_angle to 0. // °
    set scale_factor to 1. // -
    set alt_diff to scale_factor * ship:body:atm:height - switch_altitude.
    if ship:altitude >= switch_altitude {
        set pitch_angle to max(0, min(90, 90 * sqrt((ship:altitude - switch_altitude) / alt_diff))).
    }
    return pitch_angle.
}