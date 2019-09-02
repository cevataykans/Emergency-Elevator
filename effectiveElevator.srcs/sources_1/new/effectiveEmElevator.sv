`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2018 05:09:16 PM
// Design Name: 
// Module Name: effectiveEmElevator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module effectiveEmElevator( input logic clk_in, system_reset, clk_reset, // system control
                            incF1, decF1, incF2, decF2, incF3, decF3, // For increasing or decreasing floor values
                            go,
                            output logic [3:0]fourth, [3:0]third, [3:0]second, [3:0]first, // For Seven Segment Display
                            [11:0]floor1Disp, [11:0]floor2Disp, [11:0]floor3Disp, // For 8x8 Display
                            [0:7]elevatorRedCol2, [0:7]elevatorRedCol1, [0:7]elBlueCol2, [0:7]elBlueCol1,
                            logic led
    );
    // Check
//    logic incF1, decF1, incF2, decF2, incF3, decF3;
//    switchFSM incf1( clk_in, inc1, incF1 );
//    switchFSM incf2( clk_in, inc2, incF2 );
//    switchFSM incf3( clk_in, inc3, incF3 );
//    switchFSM decf1( clk_in, dec1, decF1 );
//    switchFSM decf2( clk_in, dec2, decF2 );
//    switchFSM decf3( clk_in, dec3, decF3 );
    
    // State Bits
    logic S3 = {1'b0};
    logic S2 = {1'b0};
    logic S1 = {1'b0};
    logic S0 = {1'b0};
    
    // Next State Bits and imaginary states
    logic S3P, S2P, S1P, S0P, tempS1, tempS0;
    
    // Internal Control Variables
    logic action, finish, elMSB, direction;
    logic f1, f2, f3, e14, e24, e34, go1, go2;
    
    logic twoOrThree = {1'b1};
    // Internal Clock signals
    logic clk_for_fsm, clk_out_1Sec, clk_out_10Sec, clk_out_100Sec;
    
    // Data holders
    logic [3:0]realF1, realF2, realF3;
    logic [2:0]realEl;
    
    // Starting the System and if conditons suitable ending it
    startButtonFSM oneButtonToruleThemAll( system_reset, go, finish, clk_in, action );
    endCondition     oneLogicToEndThemAll( S3, S2, S1, S0, f3, f2, f1, finish );
    // Clock Controller For Love
    clockDivider myClock( clk_in, action, twoOrThree, clk_for_fsm, clk_out_1Sec, clk_out_10Sec, clk_out_100Sec );
    
    // State Registers
    always_ff@( posedge clk_for_fsm, posedge system_reset )
        if ( system_reset )
            S0 <= 0;
        else   
            S0 <= S0P;
   
    always_ff@( posedge clk_for_fsm, posedge system_reset )
        if ( system_reset ) 
            S1 <= 0;
        else
            S1 <= S1P;
            
    always_ff@( posedge clk_for_fsm, posedge system_reset )
        if ( system_reset )
            S2 <= 0;
        else
            S2 <= S2P;
        
    always_ff@( posedge clk_for_fsm, posedge system_reset )
        if ( system_reset )
            S3 <= 0;
        else
            S3 <= S3P;
        
    // Next State Decoder
    stateDecoder            nextStateLogic( S3, S2, S1, S0, action, f1, f2, f3, e14, e24, e34, go1, go2, elMSB, S3P, S2P, S1P, S0P );
    stateConverter             myConverter( S3, S2, S1, S0, tempS1, tempS0, direction );
    
    // Determining amount of wait
    always_comb
    begin
        twoOrThree = S0 | S3;
    end
    
    // Handling passengers and the elevator
    elevatorFloorSizeAdjuster     bigLogic( clk_in, S3, S2, S1, S0, action, system_reset,
                                            incF1, decF1, incF2, decF2, incF3, decF3,
                                            f1, f2, f3, go1, go2, e14, e24, e34, elMSB,
                                            realEl, realF1, realF2, realF3 );

    // Manipulating floor and elevator values to Display
    floorSizeDisplayDecoder  floor1Display( realF1, floor1Disp );
    floorSizeDisplayDecoder  floor2Display( realF2, floor2Disp );
    floorSizeDisplayDecoder  floor3Display( realF3, floor3Disp );
    
    elevatorRedDisplay        myRedDisplay( tempS1, tempS0, realEl, elevatorRedCol2, elevatorRedCol1 );
    elevatorBlueDisplay      myBlueDisplay( tempS1, tempS0, realEl, elBlueCol2, elBlueCol1 );
    
    // General Outputs  
    upOrDown             movementDirection( clk_in, direction, action, fourth );
    secondsAdjuster           secondDiplay( clk_out_1Sec, clk_out_10Sec, clk_out_100Sec, clk_reset, third, second, first );
    assign led = finish;
endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


module stateConverter( input logic s3, s2, s1, s0, output logic tempS1, tempS0, direction );
    logic [3:0]curState;
    logic [2:0]nextState;
    
    //assign tempS1 = s2 | s1 | ( ~s0 & s3 );
    //assign tempS0 = s0 | ( s2 & s1 ) | ( s1 & ~s0 );
   
    assign curState = { s3, s2, s1, s0 }; 
//    always_comb
//        begin
//            case( curState )
//                4'b0000 : nextState = 3'b100;
//                4'b0001 : nextState = 3'b101;
//                4'b0010 : nextState = 3'b001;
//                4'b0011 : nextState = 3'b110;
//                4'b0100 : nextState = 3'b010;
//                4'b0101 : nextState = 3'b111;
//                4'b0110 : nextState = 3'b011;
//                4'b0111 : nextState = 3'b011;
//                4'b1000 : nextState = 3'b010;
//                4'b1001 : nextState = 3'b001;
//            endcase
//        end
    always_comb
        begin
            case( curState )
                4'b0000 : nextState = 3'b100;
                4'b0001 : nextState = 3'b101;
                4'b0010 : nextState = 3'b001;
                4'b0011 : nextState = 3'b110;
                4'b0100 : nextState = 3'b010;
                4'b0101 : nextState = 3'b111;
                4'b0110 : nextState = 3'b011;
                4'b0111 : nextState = 3'b010;
                4'b1000 : nextState = 3'b001;
                4'b1001 : nextState = 3'b000;
            endcase
        end

    assign tempS1 = nextState[1];
    assign tempS0 = nextState[0];
    assign direction = nextState[ 2];
endmodule


module stateDecoder( input logic S3, S2, S1, S0, action, has1, has2, has3, e14, e24, e34, can1, can2, elMSB,
                     output logic S3P, S2P, S1P, S0P );
         logic [13:0]cur;
         logic [3:0]nextState;
         
         assign cur = { S3, S2, S1, S0, action, has1, has2, has3, e14, e24, e34, can1, can2, elMSB };
         
         always_comb
            begin
                casez( cur )
                14'b0000_0????????? : nextState = 4'b0000;
                14'b0000_11???????? : nextState = 4'b0001;
                14'b0000_1?1??????? : nextState = 4'b0001;
                14'b0000_1??1?????? : nextState = 4'b0001;
                14'b0000_?000?????? : nextState = 4'b0000;
                
                14'b0001_????1????? : nextState = 4'b0010;
                14'b0001_?100?????? : nextState = 4'b0010;
                14'b0001_??1?0????? : nextState = 4'b0011;
                14'b0001_???10????? : nextState = 4'b0011;
                14'b0001_????01???? : nextState = 4'b0011;
                14'b0001_????0?1??? : nextState = 4'b0011;
                
                14'b0010_?????????? : nextState = 4'b1001;
                
                14'b0011_?????1???? : nextState = 4'b0100;
                14'b0011_??10?????? : nextState = 4'b0100;
                14'b0011_?????01??? : nextState = 4'b0101;
                14'b0011_???1?0???? : nextState = 4'b0101;
                
                14'b0100_?????????? : nextState = 4'b1000;
                
                14'b0101_?????????? : nextState = 4'b0110;
                
                14'b0110_?????????? : nextState = 4'b0111;
                
                14'b0111_?????????1 : nextState = 4'b1000;
                14'b0111_????????0? : nextState = 4'b1000;
                14'b0111_??0??????? : nextState = 4'b1000;
                14'b0111_??1?????10 : nextState = 4'b0100;
                
                14'b1000_?????????1 : nextState = 4'b1001;
                14'b1000_???????0?? : nextState = 4'b1001;
                14'b1000_?0???????? : nextState = 4'b1001;
                14'b1000_?1?????1?0 : nextState = 4'b0010;
                
                14'b1001_?????????? : nextState = 4'b0000;
                endcase
            end
            
        assign S3P = nextState[ 3];
        assign S2P = nextState[ 2];     
        assign S1P = nextState[ 1];     
        assign S0P = nextState[ 0];                  
endmodule


module elevatorBlueDisplay( input logic s1, s0, [2:0]elevatorDisplay, output logic [0:7]col2, col1 );
    logic [4:0]cur;
    
    assign cur = { s1, s0, elevatorDisplay };
    always_comb
    begin
        case( cur )
            5'b11000 : col1 = 8'b11000000;
            5'b11001 : col1 = 8'b01000000;
            5'b11010 : col1 = 8'b01000000;
            5'b11011 : col1 = 8'b00000000;
            5'b11100 : col1 = 8'b00000000;
            
            5'b10000 : col1 = 8'b00110000;
            5'b10001 : col1 = 8'b00010000;
            5'b10010 : col1 = 8'b00010000;
            5'b10011 : col1 = 8'b00000000;
            5'b10100 : col1 = 8'b00000000;
            
            5'b01000 : col1 = 8'b00001100;
            5'b01001 : col1 = 8'b00000100;
            5'b01010 : col1 = 8'b00000100;
            5'b01011 : col1 = 8'b00000000;
            5'b01100 : col1 = 8'b00000000;
            
            5'b00000 : col1 = 8'b00000011;
            5'b00001 : col1 = 8'b00000001;
            5'b00010 : col1 = 8'b00000001;
            5'b00011 : col1 = 8'b00000000;
            5'b00100 : col1 = 8'b00000000;
            
            default  : col1 = 8'b00000000;
        endcase
    end
        
    always_comb
    begin
        case( cur )
            5'b11000 : col2 = 8'b11000000;
            5'b11001 : col2 = 8'b11000000;
            5'b11010 : col2 = 8'b01000000;
            5'b11011 : col2 = 8'b01000000;
            5'b11100 : col2 = 8'b00000000;
                    
            5'b10000 : col2 = 8'b00110000;
            5'b10001 : col2 = 8'b00110000;
            5'b10010 : col2 = 8'b00010000;
            5'b10011 : col2 = 8'b00010000;
            5'b10100 : col2 = 8'b00000000;
                    
            5'b01000 : col2 = 8'b00001100;
            5'b01001 : col2 = 8'b00001100;
            5'b01010 : col2 = 8'b00000100;
            5'b01011 : col2 = 8'b00000100;
            5'b01100 : col2 = 8'b00000000;
                    
            5'b00000 : col2 = 8'b00000011;
            5'b00001 : col2 = 8'b00000011;
            5'b00010 : col2 = 8'b00000001;
            5'b00011 : col2 = 8'b00000001;
            5'b00100 : col2 = 8'b00000000;
            
            default  : col2 = 8'b00000000;
        endcase
    end    
endmodule


module elevatorRedDisplay( input logic s1, s0, [2:0]elevatorDisplay, output logic [0:7]col2, col1 );
    logic [4:0]cur;
    
    assign cur = { s1, s0, elevatorDisplay };
    always_comb
    begin
        case( cur )
            5'b11000 : col1 = 8'b00000000;
            5'b11001 : col1 = 8'b10000000;
            5'b11010 : col1 = 8'b10000000;
            5'b11011 : col1 = 8'b11000000;
            5'b11100 : col1 = 8'b11000000;
            
            5'b10000 : col1 = 8'b00000000;
            5'b10001 : col1 = 8'b00100000;
            5'b10010 : col1 = 8'b00100000;
            5'b10011 : col1 = 8'b00110000;
            5'b10100 : col1 = 8'b00110000;
            
            5'b01000 : col1 = 8'b00000000;
            5'b01001 : col1 = 8'b00001000;
            5'b01010 : col1 = 8'b00001000;
            5'b01011 : col1 = 8'b00001100;
            5'b01100 : col1 = 8'b00001100;
            
            5'b00000 : col1 = 8'b00000000;
            5'b00001 : col1 = 8'b00000010;
            5'b00010 : col1 = 8'b00000010;
            5'b00011 : col1 = 8'b00000011;
            5'b00100 : col1 = 8'b00000011;
            default  : col1 = 8'b00000000;
        endcase
    end
        
    always_comb
    begin
        case( cur )
            5'b11000 : col2 = 8'b00000000;
            5'b11001 : col2 = 8'b00000000;
            5'b11010 : col2 = 8'b10000000;
            5'b11011 : col2 = 8'b10000000;
            5'b11100 : col2 = 8'b11000000;
                    
            5'b10000 : col2 = 8'b00000000;
            5'b10001 : col2 = 8'b00000000;
            5'b10010 : col2 = 8'b00100000;
            5'b10011 : col2 = 8'b00100000;
            5'b10100 : col2 = 8'b00110000;
                    
            5'b01000 : col2 = 8'b00000000;
            5'b01001 : col2 = 8'b00000000;
            5'b01010 : col2 = 8'b00001000;
            5'b01011 : col2 = 8'b00001000;
            5'b01100 : col2 = 8'b00001100;
                    
            5'b00000 : col2 = 8'b00000000;
            5'b00001 : col2 = 8'b00000000;
            5'b00010 : col2 = 8'b00000010;
            5'b00011 : col2 = 8'b00000010;
            5'b00100 : col2 = 8'b00000011;
            default  : col2 = 8'b00000000;
        endcase
    end    
endmodule


module clockDivider( input logic clk_in, action, twoOrThree,
                     output logic clk_for_fsm, clk_out_1Sec, clk_out_10Sec, clk_out_100Sec );
    
    // Internal variables
    logic [33:0] count100 =     { 34{ 1'b0 } };
    logic [29:0] count10 =      { 30{ 1'b0 } };
    logic [28:0] count3 =       { 29{ 1'b0 } };
    logic [27:0] count2 =       { 28{ 1'b0 } };
    logic [27:0] countSeconds = { 28{ 1'b0 } };
    
    // Seven Segments Seconds Counter
    always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( countSeconds < 27'b101111101011110000011111110  )  //101111101011110000100000000 original 1 sec
                    countSeconds <= countSeconds + 1;
                else
                    countSeconds <= 0;
            else
                countSeconds <= 0;
        end
        
    assign clk_out_1Sec = ( countSeconds == 27'b101111101011110000011111110  );
    
    // Seven segments 10 secs counter as I couldnt resolve the bug :/
    always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( count10 < 30'b111011100110101100101000000000 )
                    count10 <= count10 + 1;
                else
                    count10 <= 0;
            else
                count10 <= 0;
        end
          
    assign clk_out_10Sec = ( count10 == 30'b111011100110101100101000000000 );
    
    // Seven segments 100 secs counter as I couldnt resolve the bug :/
    always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( count100 < 34'b1001010100000010111110010000000000 )
                    count100 <= count100 + 1;
                else
                    count100 <= 0;
            else
                count100 <= 0;
        end
          
    assign clk_out_100Sec = ( count100 == 34'b1001010100000010111110010000000000 );
    
    // Counter for Elevetor FSM that moves for 3 seconds and waits for 2 seconds
    always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( twoOrThree ) // changed == to 1'b1 to just opposite
                    if ( count3 < 29'b10001111000011010001100000000 )
                        count3 <= count3 + 1;
                    else
                        count3 <= 0;
                else
                    count3 <= 0; 
            else
                count3 <= 0;
        end
     
     always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( ~twoOrThree )
                    if ( count2 < 28'b1011111010111100001000000000 )
                        count2 <= count2 + 1;
                    else
                        count2 <= 0;
                else
                    count2 <= 0;
            else
                count2 <= 0;
        end
                         
     assign clk_for_fsm = ( ( count3 == 29'b10001111000011010001100000000 ) & twoOrThree ) | 
                          ( ( count2 == 28'b1011111010111100001000000000 ) & ~twoOrThree );
    
endmodule

module startButtonFSM( input logic system_reset, start, finish, clk_in,
                       output logic action );
   
    // State Bits                   
    logic S0 = { 1'b0 }; 
    logic S0P;
    
    always_ff@( posedge clk_in, posedge system_reset )
        if ( system_reset )
             S0 <= 0;
        else
             S0 <= S0P;
        
    assign S0P = ( ~S0 & start ) | ( S0 & ~finish );
    
    assign action = S0;        
endmodule

module endCondition( input logic S3, S2, S1, S0, f3, f2, f1,
                     output logic finish );
                     
    assign finish = ( ~f3 ) & ( ~f2 ) & ( ~f1 ) & ( S3 == 1'b0 ) & ( S2 == 1'b0 ) & ( S1 == 1'b0 ) & ( S0 == 1'b0) ;
endmodule

//module switchFSM( input logic clk_in, bf5, output logic out );
//    logic s1 = {1'b0};
//    logic s0 = {1'b0};
//    logic s1p, s0p;
    
//    always_ff@( posedge clk_in )
//        s1 <= s1p;
//    always_ff@( posedge clk_in )
//        s0 <= s0p;
        
//    assign s1p = ( bf5 & s0 ) | ( bf5 & s1 );
//    assign s0p = ( ~s1 & ~s0 & bf5 );
//    assign out = ( ~s1 & ~s0 & bf5 );
//endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


module secondsAdjuster( input logic sevSegSecTime, sevenSeg10SecTime, sevenSeg100SecTime, clk_reset, output logic [3:0]third, second, first );
    logic [3:0]firstD = {4'b0000};
    logic [3:0]secondD = {4'b0000};
    logic [3:0]thirdD = {4'b0000};
    logic [3:0]firstDP, secondDP, thirdDP;
    logic incSecDigit;
    logic incThirdDigit;
    logic checkF, checkS;
    
    always_ff@( posedge sevSegSecTime, posedge clk_reset )
        begin
            if ( clk_reset )
                firstD <= 4'b0000;
            else if ( firstD < 4'b1001 )
                firstD <= firstD + 1;
            else
                firstD <= 4'b0000;
        end
        
    always_ff@( posedge sevenSeg10SecTime, posedge clk_reset  )
        begin
        if ( clk_reset )
            secondD <= 4'b0000;
        else  if ( secondD < 4'b1001 )
            secondD <= secondD + 1;
        else
            secondD <= 4'b0000;
        end

    always_ff@( posedge sevenSeg100SecTime, posedge clk_reset )
        begin
        if ( clk_reset )
            thirdD <= 4'b0000;
        else if ( thirdD < 4'b1001 )
            thirdD <= thirdD + 1;
        else
            thirdD <= 4'b0000;
        end 
        
    assign third = thirdD;
    assign second = secondD;
    assign first = firstD;
endmodule

module upOrDown( input logic clk_in, direction, action, output logic [3:0]upOrDown );
    logic [3:0]cur = {4'b1010};
    logic [27:0]ms250 = {28{ 1'b0 } };
    logic clk_out;
    
    always_ff@( posedge clk_in )
        begin
            if ( action )
                if ( ms250 < 25'b1011111010111100001000000 )
                    ms250 <= ms250 + 1;
                else
                    ms250 <= 0;
            else
                ms250 <= 0;
        end
    
    assign clk_out = ( ms250 == 25'b1011111010111100001000000 );
    assign upOrDown = cur;
    
    always_ff@( posedge clk_out )
        begin
            if ( direction )
                if ( cur < 4'b1111 )
                    cur <= cur + 1;
                else
                    cur <= 4'b1010;
            else
                if ( cur > 4'b1010 )
                    cur <= cur - 1;
                else
                    cur <= 4'b1111;    
        end
    
endmodule


module floorSizeDisplayDecoder( input logic [3:0] floorSize, output logic [11:0] display );
    
    always_comb
        casez( floorSize )
            4'b0000 : display <= 12'b000000000000;
            4'b0001 : display <= 12'b000000000001;
            4'b0010 : display <= 12'b000000000011;
            4'b0011 : display <= 12'b000000000111;
            4'b0100 : display <= 12'b000000001111;
            4'b0101 : display <= 12'b000000011111;
            4'b0110 : display <= 12'b000000111111;
            4'b0111 : display <= 12'b000001111111;
            4'b1000 : display <= 12'b000011111111;
            4'b1001 : display <= 12'b000111111111;
            4'b1010 : display <= 12'b001111111111;
            4'b1011 : display <= 12'b011111111111;
            4'b1100 : display <= 12'b111111111111;
            default : display <= 12'b000000000000;
         endcase

endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


module elevatorFloorSizeAdjuster( 
                             input logic clk_in, s3, s2, s1, s0, action, system_reset, inc1, dec1, inc2, dec2, inc3, dec3,
                             output logic f1, f2, f3, g1, g2, e14, e24, e34, elevatorMSB,
                             [2:0]elToDisp, [3:0]floor1ToDisplay, [3:0]floor2ToDisplay, [3:0]floor3ToDisplay );

    logic [2:0]addPass, decPass3, decPass2, decPass1;
    
    // Adding or decreasing passengers from the floor
    pleaseDetermine3       f3Out( clk_in, system_reset, action, s3, s2, s1, s0, inc1, dec1, decPass3, floor3ToDisplay );
    pleaseDetermine2       f2Out( clk_in, system_reset, action, s3, s2, s1, s0, inc2, dec2, decPass2, floor2ToDisplay );
    pleaseDetermine1       f1Out( clk_in, system_reset, action, s3, s2, s1, s0, inc3, dec3, decPass1, floor1ToDisplay );
    elevatorSize           elOut( clk_in, system_reset, s3, s2, s1, s0, addPass, elToDisp );
    whatToGiveFloorAndEl nextOut( s3, s2, s1, s0, floor1ToDisplay, floor2ToDisplay, floor3ToDisplay, elToDisp, g1, g2, addPass, decPass3, decPass2, decPass1 ); 
    
    assign f3 =( floor3ToDisplay > 1'b0 );
    assign f2 =( floor2ToDisplay > 1'b0 );
    assign f1 =( floor1ToDisplay > 1'b0 );
    
    assign e34 = ( floor3ToDisplay >= 3'b100 );
    assign e24 = ( floor2ToDisplay >= 3'b100 );
    assign e14 = ( floor1ToDisplay >= 3'b100 );
    
    assign elevatorMSB = ( elToDisp == 3'b100 );       
endmodule


module whatToGiveFloorAndEl( input logic s3, s2, s1, s0, [3:0]fromF1, fromF2, fromF3, [2:0]fromEl,
                             output logic g1, g2, [2:0]toEl, toF3, toF2, toF1);
    //Elevator Variables
    logic [2:0]curEl;
    
    //Floor Variables
    logic [2:0]tempF1, tempF2, tempF3;
    logic [2:0]decF1, decF2, decF3;
    logic [2:0]sum23E, sum12E;
    logic checkF1, checkF2, checkF3;
    
    //Internal Variable
    logic [3:0]curState;
    
    iCanTakeFrom fromElevator( fromEl, curEl );
    iCanGiveYou    fromFloor1( fromF1, tempF1 );
    iCanGiveYou    fromFloor2( fromF2, tempF2 );
    iCanGiveYou    fromFloor3( fromF3, tempF3 );
    
//    always_comb
//        begin
//            sum23E = curEl + tempF2;
//            g2 = ( sum23E <= 3'b100 );
            
//            sum12E = curEl + tempF1;
//            g1 = ( sum12E <= 3'b100 );
//        end
    assign sum23E = fromEl + tempF2;
    assign g2 = ( sum23E <= 3'b100 );
            
    assign sum12E = fromEl + tempF1;
    assign g1 = ( sum12E <= 3'b100 );
    
    assign curState = { s3, s2, s1, s0 };
    
    // For Floor 1
    always_comb
        begin
            case( curState )
                4'b0010 : decF1 = tempF1;
                default : decF1 = 3'b000;
            endcase
        end
        
    // For Floor 2
    always_comb
        begin
            case( curState )
                4'b0100 : decF2 = tempF2;
                default : decF2 = 3'b000;
            endcase
        end
        
    // For Floor 3
    always_comb
        begin
            case( curState )
                4'b0110 : decF3 = tempF3;
                default : decF3 = 3'b000;
            endcase
        end
    
    assign checkF1 = ( decF1 >= curEl );
    assign checkF2 = ( decF2 >= curEl );
    assign checkF3 = ( decF3 >= curEl );
    
    mux2 decideFloor1( checkF1, curEl, decF1, toF1 );
    mux2 decideFloor2( checkF2, curEl, decF2, toF2 );
    mux2 decideFloor3( checkF3, curEl, decF3, toF3 );
   
    always_comb
        begin
            case( curState )
                4'b0010 : toEl = toF1;
                4'b0100 : toEl = toF2;
                4'b0110 : toEl = toF3;
                default : toEl = 3'b000;
            endcase
        end
    
 endmodule


// works in sim
module elevatorSize( input logic clk_in, system_reset, s3, s2, s1, s0, [2:0]sizeToAdd,
                     output logic [2:0]realElSize );
       
       logic [2:0]curE = {3'b000};
       logic [2:0]nextE;
       logic [2:0]add;  
       logic [3:0]curState;
       
       always_ff@( posedge clk_in )
          begin
             if ( system_reset )
                curE <= 3'b000;
             else
                curE <= nextE;
          end
       
       assign curState = { s3, s2, s1, s0 };
       always_comb
        begin
            case( curState )
            4'b0000 : nextE = 3'b000;
            default : nextE = add;
            endcase
        end
       
       always_comb
        begin
            add = curE + sizeToAdd;
            realElSize = curE;
        end            
endmodule


//works in sim
module pleaseDetermine3( input logic clk_in, system_reset, action, s3, s2, s1, s0, inc, dec, [2:0]sizeToDecrease, 
                         output logic [3:0]realF3Size );
    logic [3:0]curF = {4'b0000};
    logic [3:0]nextF;
    logic [3:0]decrease;
    logic [3:0]curState;
   
    always_ff@( posedge clk_in )   
        begin 
            if ( system_reset )
                curF <= 4'b0000;
            else if ( action )
                curF <= nextF;
            else if ( inc )
                if ( curF < 4'b1100 )
                    curF <= curF + 1;
                else
                    curF <= curF;
            else if ( dec )
                if ( curF > 4'b0000 )
                    curF <= curF - 1;
                else
                    curF <= curF;
        end

    assign curState = { s3, s2, s1, s0 };
    always_comb
        begin
            case( curState )
                4'b0110 : nextF = decrease;
                default : nextF = curF;
            endcase
        end

    always_comb
        begin
            realF3Size = curF;
            decrease = curF - sizeToDecrease;
        end    
endmodule

//works in sim
module pleaseDetermine2( input logic clk_in, system_reset, action, s3, s2, s1, s0, inc, dec, [2:0]sizeToDecrease, 
                         output logic [3:0]realF2Size );
    logic [3:0]curF = {4'b0000};
    logic [3:0]nextF;
    logic [3:0]decrease;
    logic [3:0]curState;
   
    always_ff@( posedge clk_in )   
        begin 
            if ( system_reset )
                curF <= 4'b0000;
            else if ( action )
                curF <= nextF;
            else if ( inc )
                if ( curF < 4'b1100 )
                    curF <= curF + 1;
                else
                    curF <= curF;
            else if ( dec )
                if ( curF > 4'b0000 )
                    curF <= curF - 1;
                else
                    curF <= curF;
        end

    assign curState = { s3, s2, s1, s0 };
    always_comb
        begin
            case( curState )
                4'b0100 : nextF = decrease;
                default : nextF = curF;
            endcase
        end

    always_comb
        begin
            realF2Size = curF;
            decrease = curF - sizeToDecrease;
        end    
endmodule

//works in sim
module pleaseDetermine1( input logic clk_in, system_reset, action, s3, s2, s1, s0, inc, dec, [2:0]sizeToDecrease, 
                         output logic [3:0]realF1Size );
    logic [3:0]curF = {4'b0000};
    logic [3:0]nextF;
    logic [3:0]decrease;
    logic [3:0]curState;
   
    always_ff@( posedge clk_in )   
        begin 
        if ( system_reset )
            curF <= 4'b0000;
        else if ( action )
            curF <= nextF;
        else if ( inc )
            if ( curF < 4'b1100 )
                curF <= curF + 1;
            else
                curF <= curF;
        else if ( dec )
            if ( curF > 4'b0000 )
                curF <= curF - 1;
            else
                curF <= curF;
        end
    
    assign curState = { s3, s2, s1, s0 };
    always_comb
        begin
            case( curState )
                4'b0010 : nextF = decrease;
                default : nextF = curF;
            endcase
        end

    always_comb
        begin
            realF1Size = curF;
            decrease = curF - sizeToDecrease;
        end    
endmodule


//Works in sim
module iCanGiveYou( input logic [3:0]floorValue, output logic [2:0]floorValueToDecrease);
     
    logic c4, c3, c2, c1;
    logic [3:0]check;
    always_comb
        begin
            c4 = ( floorValue >= 3'b100 );
            c3 = ( floorValue == 2'b11 );
            c2 = ( floorValue == 2'b10 );
            c1 = ( floorValue == 1'b1 );
        end
        
     assign check = { c4, c3, c2, c1 }; 
     always_comb
        case( check )
            4'b1000 : floorValueToDecrease = 3'b100;
            4'b0100 : floorValueToDecrease = 3'b011;
            4'b0010 : floorValueToDecrease = 3'b010;
            4'b0001 : floorValueToDecrease = 3'b001;
            default : floorValueToDecrease = 3'b000;
        endcase
 endmodule
 
 //Works in sim
 module iCanTakeFrom( input logic [2:0]curElValue, output logic [2:0]elValueToAdd );
 
     logic c4, c3, c2, c1, c0;
     logic [4:0]check;
     always_comb
         begin
             c4 = ( curElValue == 3'b100 );
             c3 = ( curElValue == 3'b011 );
             c2 = ( curElValue == 3'b010 );
             c1 = ( curElValue == 3'b001 );
             c0 = ( curElValue == 3'b000 );
         end
     
     assign check = { c4, c3, c2, c1, c0 };
     always_comb
     begin
         case( check )
             5'b10000 : elValueToAdd = 3'b000;
             5'b01000 : elValueToAdd = 3'b001;
             5'b00100 : elValueToAdd = 3'b010;
             5'b00010 : elValueToAdd = 3'b011;
             5'b00001 : elValueToAdd = 3'b100;
         endcase
     end
 endmodule
 
 module mux2( input logic c, [2:0]one, zero, output logic [2:0]out );
    assign out = c ? one : zero;
 endmodule