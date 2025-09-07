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
runpath("0:/kOS_Tools/Tool_Pitch_program.ks").

clearScreen.
sas off.
rcs off.

lock throttle to 0.5.
set phase_mode to "launch".
set target_apoapsis to 100_000.
lock steering to heading(90, 90). // °
// heading(direction, pitch)
// East = 90° ; North = 0° ; South° = 180° ; West = 270°

print("Start countdown ...") at (0, 0).
countdown(2).
stage.
print("Lift off!").

clearScreen.
print("Telemetry:").
print("--------------------------------") at (0, 1).
print("Altitude   :") at (0, 2). print("m:") at (20, 2).
print("Apoapsis   :") at (0, 3). print("m:") at (20, 3).
print("Pitch      :") at (0, 4). print("°:") at (20, 4).
print("Phase mode :") at (0, 10).


until phase_mode = "orbit" {
    set pitch to pitch_program().
    lock steering to heading(90, 90-pitch).

    if ship:apoapsis >= 100_000 * 0.95 {
        lock throttle to 0.1.
    }

    if ship:apoapsis >= 100_000 {
        lock throttle to 0.
        set phase_mode to "suborbital".
    }

    if phase_mode = "suborbital" {
        set target_apoapsis to ship:apoapsis.
        set mu to ship:body:mu.
        set apo to target_apoapsis.
        set body_radius to ship:body:radius.
        set a to ship:orbit:semimajoraxis.

        set v1 to sqrt(mu * ((2/(apo + body_radius)) - (1/a))).
        set v2 to sqrt(mu / (apo + body_radius)).
        set delta_v to v2 - v1.

        print("Δv required:") at (0, 10). 
        print(round(delta_v,1)) at (20, 10). print("m/s") at (30, 10).
        set circularization_node to node(timespan(0,0,0,0, eta:apoapsis), 0, 0, delta_v).
        add circularization_node.
        // set phase_mode to "circularization".
        set target_direction to circularization_node:deltav.
        lock steering to circularization_node:deltav.
        until vAng(ship:facing:forevector, target_direction) < 2 {
            wait(0.1).
        }
        warpTo(time:seconds + eta:apoapsis - 30).

        SET mass_tot TO SHIP:MASS * 1000. // Masse en kg
        LIST ENGINES IN engList.
        FOR eng IN engList {
            IF eng:IGNITION AND NOT eng:FLAMEOUT {
                SET thrust TO thrust + eng:AVAILABLETHRUST.
                SET isp TO isp + eng:ISP * eng:AVAILABLETHRUST.
            }
        }

        clearscreen.
        set g0 to 9.81.
        set mdot to thrust / (isp * g0).
        set burn_duration to mass_tot * (1 - constant:e^(-delta_v / (isp * g0))) / mdot.
        lock steering to circularization_node:deltav.
        set burn_time to time:seconds + circularization_node:eta - (burn_duration/2).
        print(burn_time) at (0,0).
        until time:seconds > burn_time {
            print("ETA       : " + time:seconds + " s      ") at (0, 0).
            print("burn time : " + burn_time +    " s      ") at (0, 1).
            wait(0.01).
        }

        lock throttle to 1.
        UNTIL circularization_node:DELTAV:MAG < 0.01 {
            PRINT "Delta-V restant : " + ROUND(circularization_node:DELTAV:MAG, 2) + " m/s." at (0, 10).
            if circularization_node:deltav:mag < 5 {
                lock throttle to 0.02.
            }
            WAIT 0.01.
        }
        lock throttle to 0.

        remove circularization_node.
    }

    print(round(ship:altitude)) at (10, 2).
    print(round(ship:apoapsis)) at (10, 3).
    print(round(90-pitch, 2)) at (10, 4).
    wait(0.05).
}.