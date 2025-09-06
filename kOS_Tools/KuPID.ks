// KuPID.ks
// Détermine le Ku d'un régulateur PID par la méthode de Ziegler-Nichols

clearScreen.

local titre is ship:name + " - Recherche du Ku (Gain limite)".

global function afficheTitre {
    parameter title.
    print "--------------------------------------------------"  at (0, 0).
    print title                                                 at (round((50 - title:length) / 2), 2).
    print "--------------------------------------------------"  at (0, 4).

}

afficheTitre(titre).

// Parametres
parameter Ku is 1.
parameter Tu is 0.

// Variables locales
local fin   is false.   // définit la fin de l'enregistrement
local power is 0.       // Contrôle de la poussée
local t0    is 0.       // Top chrono

sas off.
rcs off.

// Calcul altitude terrain
local offset is ship:altitude - ship:geoposition:terrainheight.
lock AGL to ship:altitude - ship:geoposition:terrainheight - offset.

// Contrôle de la poussée et de la direction
lock throttle   to power.
lock steering   to up.

// Configuration du PID
local Kp is Ku.
local Ki is 0.
local Kd is 0.

local KpIni is Ku.
set KpIni to KpIni * 1.

// Paramétrage final du coorecteur
if Tu <> 0
{
    set Kp to 0.6 * Ku.
    set Ki to 1.2 * Ku / Tu.
    set Kd to 3.0 * Ku * Tu / 40.
}
local VPID is pidLoop(Kp, Ki, Kd, 0, 1).
set VPID:setpoint to 0.
print "PID configuré" at (0, 6).

// Activation du 1er étage avec moteur disponible
until ship:availablethrust > 0 stage.

// Décollage et montée à 5m
set power to 1.
wait until AGL > 5.

// Ouverture du fichier des données enregistrées
log "Temps," + "Gaz," + "Vvert" to ship:name + "_" + KpIni + ".csv".
log 0 + "," + power + "," + ship:verticalspeed to ship:name + "_" + KpIni + ".csv".

// Top Chrono
VPID:reset().
set t0 to time:seconds.

until ship:status = "LANDED"
{
    clearScreen.
    afficheTitre(titre).

    // Régulation de la pussance en fonction de la vitesse
    set power to VPID:update(time:seconds, ship:verticalspeed).

    // Afichage des infos
    print "Gaz      : " + round(100 * power, 2)         + " %"               at (0, 6).
    print "VertSpd  : " + round(ship:verticalspeed, 2)  + " m/s"             at (0, 7).
    print "Erreur   : " + round(VPID:error, 2)          + " m/s"             at (0, 8).
    print "Kp       : " + Kp                                                at (0, 9).
    print "Ku       : " + Ku                                                at (0, 10).

    // Enregistrement des paramètres
    if not fin log (time:seconds - t0) + "," + power + "," + ship:verticalspeed to ship:name + "_" + KpIni + ".csv".

    // Arrêt de l'enregistrement et déclenchement de la descente après 5 secondes de vol
    if not fin and time:seconds - t0 > 5
    {
        set fin to true.
        set VPID:setpoint to -1.
        if Tu = 0.
        {
            set Ku to Kp.
            set Kp to 1 * Ku.
        }
    }

    // Passer un "physic tick"
    wait 0.
}
clearScreen.
print "Essai Terminé " at (0,12).
if Tu = 0 // Affichage du Ku
{
    print "Ku = " + Ku at (0, 16).
}
else // Affichage du paramètre du régulateur
{
    print "Kp = " + round(Kp, 2) at (0, 15).
    print "Ki = " + round(Ki, 2) at (0, 16).
    print "Kd = " + round(Kd, 2) at (0, 17).
}
lock throttle to 0.

// movePath("1:/" + ship:name + "_" + KpIni + ".csv", "0:/").

print "Envoi des données au centre spatial" at (0, 13).