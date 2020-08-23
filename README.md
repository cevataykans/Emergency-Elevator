# Effective Elevator

## About Project

>This project is an end class project of cs223. In this project, knowledge of applying hardware design and System Verilog is used for the scenario of an emergency elevator which must complete extraction of a building in the most efficient way possible. This project may be used as a reference for digital design and System Verilog.

## Detailed Information

**HSML Diagram**
![HSML](https://github.com/cevataykans/emergency-elevator/blob/master/HSML_Diagram.png)


**Logic Behind FSM**

  To make a time-efficient elevator, first, I have decided beginning from floor1 to floor3, the elevator should only collect passengers that are equal to 4 or more on the floors. This way, since the elevator would always be full, the time spent between floors and on the floors is the same. Time efficiency begins when every floor has less than 4 passengers. In this case, elevator travels to floor3 if there are any remaining passengers, else floor2, worst case, floor1. When the elevator collects passengers from floor3, it should decide whether it should stop by floor2 or not. If there are not any passengers on floor2, it continues to the floor1, however, if there are passengers left on floor2, the elevator looks for a second condition. The elevator stops by the floor2 only if the sum of remaining passengers and the elevator passengers are equal or less than 4. If this condition is not checked, after stopping on the floor2, there could still be passengers on the floor2 after collection, therefore elevator has to travel to this floor again, meaning it would stop by this floor twice. In the case of this, the elevator would not stop by to collect passengers and travel to floor2 only once. This logic applies to all states. Therefore, the elevator becomes time efficient. The inputs which decide what the elevator should do on each state, come from the data path that holds the values of floors and the current elevator capacity. The outputs from this state to the data path are the state bits to adjust floor and elevator sizes, clk to decide 2 or 3 seconds, and the direction of the elevator to determine the shifting direction of the fourth seven segments display.


**FSM Diagram Inputs**

* system_reset: Resets the system to the initial state.

* action: Indication of if the simulation has started or not.

* f1: ( floor1 value > 4’b0000 ), indicates there are passengers on floor1.
* f2: ( floor2 value > 4’b0000 ), indicates there are passengers on floor2.
* f3: ( floor3 value > 4’b0000 ), indicates there are passengers on floor3.

* f1has4: ( floor1 value >= 3’b100 ), indicates there are more than four passengers.
* f2has4: ( floor2 value >= 3’b100 ), indicates there are more than four passengers.
* f3has4: ( floor3 value >= 3’b100 ), indicates there are more than four passengers.

* elfull: ( Elevator value == 3’b100 ), indicates elevator has the maximum passengers.

* moveF1: ( Elevator value + floor1 value <= 3’b100 ), indicates elevator can gather passengers from floor 1 without losing extra time.
* moveF2: ( Elevator value + floor2 value <= 3’b100 ), indicates elevator can gather passengers from floor 1 without losing extra time.


**FSM Diagram Outputs**

* direction (d): indicates if the elevator is going up or down. 1 for up, 0 for down.

* clk: indicates the clock divider whether in this state clk should count for 2 seconds or 3 seconds. 1 for 3 seconds, 0 for 2 seconds.


**FSM Diagram States**

**State Encoding:**

| State | Value |
| :---: | :---: |
S0 | “0000”
S1 | “0001”
S2 | “0010”
S3 | “0011”
S4 | “0100”
S5 | “0101”
S6 | “0110”
S7 | “0111”
S8 | “1000”
S9 | “1001”


**State Descriptions:**

* S0 : This is the initial state. In this state, the elevator is at the bottom. On an 8x8 display, this would be at the very bottom of the display section. The elevator is at rest in this state, unless they are passengers on the floors. If they are passengers, however, the elevator will not move again unless the command has been given to the elevator to collect the passengers. The output of this state is 0 which means it would stay in this state for 2 seconds. Furthermore, the direction of the elevator is set to 1 to indicate it is going up if the elevator is going to move.

* S1 : This is the state where the elevator is at between floor0 and floor1. On 8x8 display. This state is displayed on floor1. If there are more than or equal to 4 passengers on the floor1, or if there are not any passengers left on the upper floors, the elevator will either stop at floor1 else it would continue to the floor2. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 1 to indicate it is going up.

* S2 : This is the state where the elevator stops at the floor1. On 8x8 display. This state is displayed on floor2. In this state, the elevator collects the passengers from floor1 and decides to move on to the S9 for bringing these passengers to the ground floor. The output of this state is 0 which means it would stay in this state for 2 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down as in this state, there are either no passengers on the upper floors or the elevator is already full from collecting passengers from this floor.

* S3 : This is the state where the elevator is at between floor1 and floor2. On 8x8 display. This state is displayed on floor2. If there are more than or equal to 4 passengers on the floor2, or if there are not any passengers left on the floor3, the elevator will either stop at floor2 else it would continue to the floor3. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 1 to indicate it is going up.

* S4 : This is the state where the elevator stops at the floor2. On 8x8 display. This state is displayed on floor2. In this state, the elevator collects the passengers from floor2 and decides to move on to the S8 for either bringing these passengers to the ground floor or collecting remaining passengers from the floor1 is there are any. The output of this state is 0 which means it would stay in this state for 2 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down as in this state, there are either no passengers on the floor3 or the elevator is already full from collecting passengers from this floor.

* S5 :This is the state where the elevator is at between floor2 and floor3. On 8x8 display. This state is displayed on floor3. If the elevator comes to this state, it would automatically stop at the floor3 (S6) as if there were not any passengers on the third floor, the elevator would not be able to reach this state. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 1 to indicate it is going up.

* S6 : This is the state where the elevator stops at the floor3. On 8x8 display. This state is displayed on floor3. In this state, the elevator collects the passengers from floor3 and decides to move on to the S7 for either bringing these passengers to the ground floor or to collect remaining passengers from the below floors. The output of this state is 0 which means it would stay in this state for 2 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down as.

* S7 : This is the state where the elevator is between floor2 and floor3, however, this time it is going down. On 8x8 display. This state is displayed on floor2. In this state, the elevator decides whether it should continue to the floor1 or should stop by the floor2 to gather passengers if the elevator is not full. However, for time efficiency, the elevator may not stop by this floor at all even if it has enough space for some passengers. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down.

* S8 : This is the state where the elevator is between floor1 and floor2, however, this time it is going down. On 8x8 display. This state is displayed on floor1. In this state, the elevator decides whether it should continue to the floor0 or should stop by the floor1 to gather passengers if the elevator is not full. However, for time efficiency, the elevator may not stop by this floor at all even if it has enough space for some passengers. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down.

* S9 : This is the state where the elevator is heading to the ground floor to bring back passengers. On 8x8 display. This state is displayed on the ground floor. The output of this state is 1 which means it would stay in this state for 3 seconds. Furthermore, the direction of the elevator is set to 0 to indicate it is going down.


**Physical Modules Used**

*8x8 Display ( Betty Board )*

This 8x8 display is used to show the observers where the elevator is currently at, how many passengers it is containing. Furthermore, it also displays how many passengers are on each floor. From this display, it can be observed how many passengers are taken into the elevator at each floor, where the elevator is, where it is going, how many passengers are in the elevator. This module always displays the current situation of the elevator and the floors.


*4X4 Keypad ( Betty Board )*

This 4X4 Keypad is not fully used. Only the last 3 rows and last 2 columns are used as buttons. The buttons on the third column decrease passengers on the floor while the fourth column increases passengers on the floors. The fourth row of buttons indicates the third floor, third row of buttons second floor, and the second row of buttons first floor. If the simulator is not started, these buttons can be used to edit passengers on each floor, however, if the simulator starts, these buttons will not have any effect on the passengers on each floor.


*Keys ( Basys3 )*

When pressed to the upper key, the simulator will start if there are not any passengers on the floors, the simulation would immediately end. When pressed to the middle key, the timer on the seven segment display will be set to zero regardless of the situation of the simulator. When pressed the down key, regardless of the situation of the simulator, everything will be set to initial condition except for the timer which would stop.


*Seven Segment ( Basys3 )*

The most significant display of the seven-segment is used to indicate the direction of the elevator if it is going up or down. If it is going up, a single segment will be shifted by the clock direction, else, it would be shifted by the counter clock direction. The remaining displays are used to display the time passed when the simulator starts.


*Led Display ( Basys3 )*

One led is used to indicate the system whether is at rest or is running. Although it is unnecessary to use such led, this makes the system sophisticated. 


**Data Path and Modules Used**

*effectiveModule Module*

Inputs:

* clk_in : 100 MHz clock of the basys3.
* system_reset : Resets the system to initial conditions.
* clk_reset : Resets the clock.
* go : Starts of the simulation.

* [3:0]keyb_col : The input for 4x4keypad module.

Outputs:

* led : I have assigned when led light to be lit when the system is at rest.

* a, b, c, d, e, f, g, dp, [3:0] an : The outputs from the seven segment module.

* reset_out, OE, SH_CP, ST_CP, DS, [7:0] col_select : outputs from the 8x8 display module.

* [3:0]keyb_row : The output from 4x4keypad module.

> In this module, there are four major modules: seven-segment, 4x4keypad, 8x8display, and the effectiveElevator. The modules besides from effectiveElevator, are given modules. This module allows communication between these modules. effectiveElevator is the module where the elevator and floor are implemented. From 4x4Keypad, effectiveElevator takes increasing or decreasing inputs regarding floors and displays the total time to the seven segments while at the same time displaying the elevator and floors on the 8x8display module.


*4x4keypad Module*

> Gets the increasing or decreasing signal from the 4x4 keypad on the betty board and returns a key_valid and key_value to enable the developer to handle the signal. This way, the floors in the effectiveElevator module can be increased or decreased.


*8x8display Module*

> Displays the floor and the elevator on the 8x8 display on the betty board. To display these, combinational logic is used. The states of the effectiveElevator and the current size of the elevator via combinational logic are used to display the first 2 columns while the rest of the columns are used to display floor values via combinational logic.


*sevSegment Module*

> The time outputs from the effectiveElevator are used as inputs in this module to display elapsed time while the MSB display showing the direction of the elevator.
effectiveElevator Module


*effectiveElevator Module*

Inputs:

* clk_in : The 100MHz clock of the basys3.

* system_reset : Resets the system to the default.

* clk_reset : Resets the clock values stored on the registers.

* go : Allows the FSM and the clock to begin.

* incF1, decF1, incF2, decF2, incF3, decF3 : increases or decreases passengers from the regarding floor if the simulation has not started yet.

Outputs:

* [3:0]fourth, third, second, first : Third, second and first is the output to the sevSegment to display elapsed time while fourth being the direction value of the elevator to be displayed.

* [11:0]floor1Disp, floor2Disp, floor3Disp : These are the floor values decoded from the four-bit floor values to be outputted to be displayed on the 8x8display.

* [0:7]elevatorRedCol2, elevatorRedCol1 : Since the elevator is constantly changing its state over time, to display where the elevator is currently at and how many passengers it has, decoders are used to determine which output to give to the 8x8display to correctly display the elevator. This logic is named red because these are decoded for blue display and are only for the first 2 columns of the 8x8Display.

* [0:7]elBlueCol2, elBlueCol1 : Since the elevator is constantly changing its state over time, to display where the elevator is currently at and how many passengers it has, decoders are used to determine which output to give to the 8x8display to correctly display the elevator. This logic is named blue because these are decoded for blue display and are only for the first 2 columns of the 8x8Display.

* led : I have assigned a single led output which is lit only when the system is at rest. 

> In this module high-level state machine design is used. There is a controller with one main FSM, one small FSM, and one combinational logic and the data path which contains four registers with complex combinational logic. For the outputs, 5 decoders are used. There is one clock divider. A total of eighteen modules are used to construct this module.

> Main FSM includes four state bits. Depending on the state, the main FSM gives the clock divider twoOrThree input which is the indication of whether the clock should count for 2 seconds or 3 seconds. With feedback from the data path, the next state is determined by a state decoder.


**Modules Used in EffectiveElevator**

*StateConverter Module ( input logic S3, S2, S1, S0, output logic tempS1, tempS0, direction )*

>In this module the current state bits are transformed into 2 bits to simply display the current state on the 8x8 display with this encoding:

* “0000”, “1001” are “00” (ground floor)
* “0001”, “0010”, “1000” are “01” ( first floor )
* “0011”, “0100”, “0111” are “10” ( second floor )
* “0101”, “0110” are “11” ( third floor )

> This module also determines the direction of the elevator which is then sent to upOrDown module.


*EndCondition Module ( input logic S3, S2, S1, S0, f3, f2, f1, output logic finish )*

> This module determines whether the system is running. f3, f2, f1 are sensors that indicate if there are any passengers on the floors. if state bits and the sensors are 0, then it is finished, 1.


*StartButtonFSM Module ( input logic system_reset, start, finish, clk_in, output logic action )*

> This module contains a small FSM with a one-bit state variable. When the user activates the simulation, the system needs to know if it is in action. When the start command is given, until there is a finish command, this FSM outputs 1 as to indicate the system is in action. On its initial state, the output is 0, indicating that the system is not running.


*StateDecoder  Module ( input logic S3, S2, S1, S0, action, f1, f2, f3, f1has4, f2has4, f3has4, moveF1, moveF2, elFull, output logic S3P, S2P, S1P, S0P )*

> This module is a decoder for determining the next state logic. How the inputs affect the state logic can be observed on the main FSM diagram where the explanation of each input could be found.


*ClockDivider Module ( input logic clk_in, action, twoOrThree, output logic, clk_for_fsm, clk_out_1sec, clk_out_10sec, clk_out_100sec )*

> This module counts for 2 or 3 seconds depending on the input from the main FSM and changes the next state with the output clk_for_fsm. Clk_out_1sec counts for every 1 second, clk_out_10sec counts for 10 seconds and clk_out_100sec counts for 100 seconds. These outputs are for displaying the total time elapsed on the seven segments. If the system is not running ( action ), no counting is done.


*SecondsAdjuster Module ( input logic sevSegSecTime, sevSeg10SecTime, sevSeg100SecTime, clk_reset, output logic [3:0]third, second, first )*

> Whenever a second passes, the first argument is increased by one. Whenever a 10 seconds pass, the second argument is increased by one. Whenever 100 seconds pass, the third argument is increased by one. If there is a clk_reset signal, these values are set to zero. The outputs are sent to the seven segment module to be displayed. Since three different counters are used for time increase, this may seem unnecessary. However, when the second argument is increased by one when first gets the value of ten, although the behavioral simulator indicates there is no problem, bugs occur and second is increased twice. By using different counters, this bug is prevented.


*UpOrDown Module ( input logic clk_in, direction, action, output logic [3:0]upOrDown )*

> This module has an internal counter which when system starts, counts for 250 ms. Depending on the direction, if 1, upOrDown is increased else it is decreased by one. On the seven-segment module, depending on the value of upOrDown, one segment is used to display the direction of the elevator.


*ElevatorFloorSizeAdjuster Module ( input logic clk_in, S3, S2, S1, S0, action, system_reset, inc1, inc2, inc3, dec1, dec2, dec3, output logic f1, f2, f3, moveF1, moveF2, f1has4, f2has4, f3has4, elFull, [2:0]elToDisp, [3:0]floor1, floor2, floor3 )*

> This module is the data path which gives feedback to the controller while also adding or decreasing passengers from the floors or the elevator. In this module, 4 modules are used as storage for floors and the elevator while a combinational logic module is used to determine what value to give each floor and the elevator to add and decrease their passengers. This module gives nine signals to the controller FSM by using the values of floor1, floor2, floor3 and the elevator. The meanings of these signals can be read on the FSM diagram inputs.


*WhatToGiveFloorAndEl Module( input logic S3, S2, S1, S0, [3:0]fromF1, fromF2, fromF3, [2:0]fromEl, output logic moveF1, moveF2, [2:0]toEl, [3:0]toF3, toF2, toF1 )*

> This module determines what signal to give each floor to decrease as well as gives the same signal to the elevator to add. Depending on the current elevator size and the floor sizes, this module determines the moveF1, moveF2 signals that affect the controller. States and current sizes of floors and the elevator are checked to determine the signal. If states do not match any floor, the elevator and every floor get the signal of zero to add and decrease. However, if states indicate that the elevator is at a floor, this module checks whether the elevator can get a passenger from the floor and if gets any, only the size of the particular floor is decreased and the elevator size is increased while other floors get the signal of zero.


*ElevatorSize Module ( input logic clk_in, system_reset, S3, S2, S1, S0, [2:0]elSizeToAdd, output logic [2:0]realElSize )*

> This module is for handling the elevator size. Each time the elevator gets on the base floor, it gets the value of zero. At other times the elevator gets the value of the current elevator size + elSizeToAdd which comes from the WhatToGiveFloorAndEl.


*Determine3 Module ( input logic clk_in, system_reset, action, S3, S2, S1, S0, inc, dec, [2:0]sizeToDecrease, output logic [3:0]realF3Size )*

> This module is for determining current floor value. If the simulation is not started, third-floor passengers can be increased with the signal inc and can be decreased with the signal dec. If the simulation starts, these signals are ignored. During the simulation, floor3 constantly gets the value of the current floor3 value decreased by the sizeToDecrease that is given by the WhatToGiveFloorAndEl module.


*Determine2 and Determine1*

> These modules use the same logic as the logic used in the Determine3 module.


*ICanGiveYou Module ( input logic [3:0]floorValue, output logic [2:0]valueToDecrease )*

> This module is used by floors to determine how many passengers a single floor can give to the elevator regarding their current size.


*ICanTakeFrom Module ( input logic [2:0]curElValue, output logic [2:0]elValueToAdd)*

> This module determines how many passengers can the elevator take with its current size.


*Mux2 Module ( input logic control, [2:0]one, zero, output logic [2:0]out )*

> This custom mux2-1 is used to choose between signals.


*FloorSizeDisplayDecoder Module ( input logic [3:0]floorSize, output logic [11:0]display)*

> This decoder decodes the four-bit size of the current floor value and outputs it into twelve bit for a simpler display on the 8x8 display.


*ElevatorRedDisplay Module ( input logic S1, S0, [2:0]elSizeToDisplay, output logic [0:7]col2, col1 )*

> This module decodes the converted state bits and the elevator size to eight-bit to display the elevator on the 8x8 display using red light.


*ElevatorBlueDisplay Module ( input logic S1, S0, [2:0]elSizeToDisplay, output logic [0:7]col2, col1 )*

> This module decodes the converted state bits and the elevator size to eight-bit to display the elevator on the 8x8 display using blue light.

