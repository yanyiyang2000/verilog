`timescale 1ns / 1ps

/*******************************************************************************
 4-digit seven-segment display.
 
 Inputs:
   clk_i:  1-bit clock signal (rising edge triggered)
           For Digilent BASYS 3 Artix 7 FPGA Trainer Board: 
             clk_i = 100 MHz oscillator (pin W5)
   
   clr_i:  1-bit clock divider clear signal (rising edge triggered)
           clr_i should be mapped to a button.
   
   en_i:   1-bit seven-segment display enable signal (active high)
           en_i should be mapped to a switch.
   
   dig3_i: 4-bit binary number to be displayed on the leftmost display (MSB)
   dig2_i: 4-bit binary number to be displayed
   dig1_i: 4-bit binary number to be displayed
   dig0_i: 4-bit binary number to be displayed on the rightmost display (LSB)
           digX_i should be connected to num_i of cathode driver.

 Outputs:
   an_o: 4-bit anode control signal (which seven-segment display to turn on)
         For Digilent BASYS 3 Artix 7 FPGA Trainer Board: 
           - an[3] = AN3 (pin W4) leftmost seven-segment display (MSB).
           - an[2] = AN2 (pin V4)
           - an[1] = AN1 (pin U4)
           - an[0] = AN0 (pin U2) rightmost seven-segment display (LSB).
   
   ca_o: 7-bit cathode control signal (which decimal number to display)
         For Digilent BASYS 3 Artix 7 FPGA Trainer Board: 
           - ca_o[6] = CA (pin W7)
           - ca_o[5] = CB (pin W6)
           - ca_o[4] = CC (pin U8)
           - ca_o[3] = CD (pin V8)
           - ca_o[2] = CE (pin U5) 
           - ca_o[1] = CF (pin V5)
           - ca_o[0] = CG (pin U7)
*******************************************************************************/
module seven_segment_display(
    input        clk_i,
    input        clr_i,
    input        en_i,
    input [3:0]  dig3_i,
    input [3:0]  dig2_i,
    input [3:0]  dig1_i,
    input [3:0]  dig0_i,
    output [3:0] an_o, 
    output [6:0] ca_o
    );
    
    wire       clk_tmp;
    wire [1:0] sel_tmp;
    reg [3:0]  num_tmp;
    
    // initialize a clock divider to prescale clock from 100 MHz to 1 kHz
    clock_divider #(.PSC(100000)) clk_divdr(
        .clk_i(clk_i),
        .clr_i(clr_i),
        .clk_o(clk_tmp)
    );
    
    // initialize an anode driver
    anode_driver a_drvr(.clk_i(clk_tmp), .en_i(en_i), .an_o(an_o), .sel_o(sel_tmp));
    
    // initialize a cathode driver
    cathode_driver c_drvr(.num_i(num_tmp), .ca_o(ca_o));
    
    always @* begin
        case (sel_tmp)
            0 : num_tmp = dig3_i; // displays on the leftmost seven-segment display
            1 : num_tmp = dig2_i;
            2 : num_tmp = dig1_i;
            3 : num_tmp = dig0_i; // displays on the rightmost seven-segment display
        endcase
    end
endmodule


/*******************************************************************************
 Seven-segment display anode driver turns on seven-segment displays ONE at a time.

 Note:
    This driver turns on a 4-digit seven-segment display sequentially from left 
    to right in 1 ms (i.e. refresh rate is 1 kHz) to make it look like all 
    displays are on at the same time.

 Inputs:
    clk_i: 1-bit clock signal (rising edge triggered)
           
    en_i:  1-bit anode enable signal (active high)

 Outputs:
    an_o:  4-bit anode control signal representing the states of the 4 anodes 
           connected to the 4-digit seven-segment display. 0 is on, 1 is off.

    sel_o: 2-bit display select signal (which seven-segment display to turn on)
*******************************************************************************/
module anode_driver(
    input            clk_i,
    input            en_i,
    output reg [3:0] an_o,
    output reg [1:0] sel_o
    );
    
    initial begin
        an_o  <= 4'b0111;
        sel_o <= 2'b00;
    end
    
    always @(posedge clk_i) begin
        if (en_i == 1) begin
            if (sel_o == 3) begin
                an_o  <= 4'b0111;
                sel_o <= 2'b00;
            end else begin
                sel_o = sel_o + 1;
                
                case (sel_o)
                    0       : an_o = 4'b0111; // turn on leftmost display
                    1       : an_o = 4'b1011;
                    2       : an_o = 4'b1101;
                    3       : an_o = 4'b1110; // turn on rightmost display
                    default : an_o = 4'bxxxx; // for troubleshooting
                endcase
            end
        end
    end
endmodule


/*******************************************************************************
 Seven-segment display cathode driver turns on certain segments of a seven-segment
 display based on the input.
 
 Note:
   This is also known as hexdecimal to seven-segment decoder that converts a 
   1-bit hexadecimal number to a 7-bit binary number.

 Input:
    num_i: 1-bit hexadecimal (4-bit binary) number to be displayed

 Output:
    ca_o:  7-bit cathode control signal representing the states of the 7 cathodes 
           connected to the seven-segment display. 0 is on, 1 is off.
*******************************************************************************/
module cathode_driver(
    input [3:0]      num_i,
    output reg [6:0] ca_o
    );
    
    always @* begin
        case (num_i)
            4'b0000 : ca_o = 7'b0000001; // '0'
            4'b0001 : ca_o = 7'b1001111; // '1'
            4'b0010 : ca_o = 7'b0010010; // '2'
            4'b0011 : ca_o = 7'b0000110; // '3'
            4'b0100 : ca_o = 7'b1001100; // '4'
            4'b0101 : ca_o = 7'b0100100; // '5'
            4'b0110 : ca_o = 7'b0100000; // '6'
            4'b0111 : ca_o = 7'b0001111; // '7'
            4'b1000 : ca_o = 7'b0000000; // '8'
            4'b1001 : ca_o = 7'b0000100; // '9'
            4'b1010 : ca_o = 7'b0001000; // 'A'
            4'b1011 : ca_o = 7'b1100000; // 'B'
            4'b1100 : ca_o = 7'b0110001; // 'C'
            4'b1101 : ca_o = 7'b1000010; // 'D'
            4'b1110 : ca_o = 7'b0110000; // 'E'
            4'b1111 : ca_o = 7'b0111000; // 'F'
        endcase
    end
endmodule
