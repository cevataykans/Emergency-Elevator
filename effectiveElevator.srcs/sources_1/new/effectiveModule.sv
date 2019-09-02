`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2018 10:47:00 PM
// Design Name: 
// Module Name: effectiveModule
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


module effectiveModule( input logic clk_in, system_reset, go, clk_reset, //incF1, decF1, incF2, decF2, incF3, decF3, for switch use only
    
    output logic led,    // for fun, indicates it has finished
    output a, b, c, d, e, f, g, dp, // just connect them to FPGA pins (individual LEDs).
    output [3:0] an,   // just connect them to FPGA pins (enable vector for 4 digits, active low)

    output reset_out, //shift register's reset
	output OE, 	//output enable, active low 
	output SH_CP,  //pulse to the shift register
	output ST_CP,  //pulse to store shift register
	output DS, 	//shift register's serial input data
	output [7:0] col_select, // active column, active high
	
	output [3:0] keyb_row,
    input  [3:0] keyb_col
    );
//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
//                   KEYPAD
//////////////////////////////////////////////////////////////////////////////////////////////////////////////     
    logic incF1 = {1'b0}; 
    logic decF1 = {1'b0};
    logic incF2 = {1'b0};
    logic decF2 = {1'b0};
    logic incF3 = {1'b0};
    logic decF3 = {1'b0};
    
    logic [3:0] key_value;
    logic key_valid;
    keypad4X4 keypad4X4_inst0(
	.clk(clk_in),
	.keyb_row(keyb_row), // just connect them to FPGA pins, row scanner
	.keyb_col(keyb_col), // just connect them to FPGA pins, column scanner
    .key_value(key_value), //user's output code for detected pressed key: row[1:0]_col[1:0]
    .key_valid(key_valid)  // user's output valid: if the key is pressed long enough (more than 20~40 ms), key_valid becomes '1' for just one clock cycle.
);	

    always@ ( posedge clk_in )
    begin
    if (key_valid == 1'b1 & key_value == 4'b01_10 )
        incF3 <= 1;
    else
        incF3 <= 0;

    if (key_valid == 1'b1 & key_value == 4'b01_11 )
        decF3 <= 1;
    else
        decF3 <= 0;
        
    if (key_valid == 1'b1 & key_value == 4'b10_10 )
        incF2 <= 1;
     else
        incF2 <= 0;   
            
    if (key_valid == 1'b1 & key_value == 4'b10_11 )
        decF2 <= 1;
    else
        decF2 <= 0;
    
    if (key_valid == 1'b1 & key_value == 4'b11_10 )
        incF1 <= 1;
    else
        incF1 <= 0;   
                    
    if (key_valid == 1'b1 & key_value == 4'b11_11 )
        decF1 <= 1;
    else
        decF1 <= 0;  
    end  
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
//                  ELEVATOR FSM DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ( ???????????? ) yes done :)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////         
    logic[7:0]redCol2, redCol1, blueCol2, blueCol1;
    logic[11:0]f1Disp, f2Disp, f3Disp;
    logic [3:0]fourth, third, second, first; // Third second first are changed for demo purposes
    effectiveEmElevator elevator( clk_in, system_reset, clk_reset, incF1, decF1, incF2, decF2, incF3, decF3, go, 
                                    fourth, third, second, first, f1Disp, f2Disp, f3Disp, redCol2, redCol1, blueCol2, blueCol1, led );

//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
//                   SEVEN SEGMENT DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////  
SevSeg_4digit mysevSeg( clk_in, first, second, third, fourth, a, b, c, d, e, f, g, dp, an );


//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
//                   8X8 DISPLAY DONE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    logic[ 0:7]col3B, col4B, col5B, col6B, col7B, col8B;
    
    assign col3B = { f3Disp[ 0], f3Disp[1], f2Disp[ 0], f2Disp[ 1], f1Disp[ 0], f1Disp[ 1], 1'b0, 1'b0 };
    assign col4B = { f3Disp[ 2], f3Disp[3], f2Disp[ 2], f2Disp[ 3], f1Disp[ 2], f1Disp[ 3], 1'b0, 1'b0 };
    assign col5B = { f3Disp[ 4], f3Disp[5], f2Disp[ 4], f2Disp[ 5], f1Disp[ 4], f1Disp[ 5], 1'b0, 1'b0 };
    assign col6B = { f3Disp[ 6], f3Disp[7], f2Disp[ 6], f2Disp[ 7], f1Disp[ 6], f1Disp[ 7], 1'b0, 1'b0 };
    assign col7B = { f3Disp[ 8], f3Disp[9], f2Disp[ 8], f2Disp[ 9], f1Disp[ 8], f1Disp[ 9], 1'b0, 1'b0 };
    assign col8B = { f3Disp[ 10], f3Disp[11], f2Disp[ 10], f2Disp[ 11], f1Disp[ 10], f1Disp[ 11], 1'b0, 1'b0 };
    
    logic [2:0]col_num;
    
    logic [0:7] [7:0] image_red = 
    { redCol1, redCol2, col3B, col4B, col5B, col6B, col7B, col8B };
 
    logic [0:7] [7:0]  image_blue = 
    { blueCol1, blueCol2, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000 };
    
    logic [0:7] [7:0]  image_green = 
    {8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};
    display_8x8 myDisplay( .clk(clk_in),
        
        // RGB data for display current column
        .red_vect_in( image_red[col_num] ),
        .green_vect_in( image_green[col_num] ),
        .blue_vect_in( image_blue[col_num] ),
        
        .col_data_capture(), // unused
        .col_num(col_num),
        
        // FPGA pins for display
        .reset_out(reset_out),
        .OE(OE),
        .SH_CP(SH_CP),
        .ST_CP(ST_CP),
        .DS(DS),
        .col_select(col_select)   );
              
endmodule
