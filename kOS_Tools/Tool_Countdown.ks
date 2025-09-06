// ____________________________________________________ //
//                                                      //
//    Tool - Countdown                                  //
// ____________________________________________________ //
// Infos   : Countdown from a given value as parameter  //
//           until 0. The time step can be choose by    //
//           using an optional parameter.               //
// Version : V0                                         //
// Example : countdown(5, 1)                            //
// ---------------------------------------------------- //

// Function
function countdown {
    parameter start.
    parameter step is 1.
    print("Start countdown:").
    wait 1.
    clearScreen.
    print("s") AT (10, 0).
    from {local i is start.}
    until i <= 0
    step {set i to i - step.}
    do {
        print("T - " + round(i, 1)) AT (0, 0). 
        wait step.
    }
}