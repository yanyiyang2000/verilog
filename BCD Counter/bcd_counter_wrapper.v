`timescale 1ns / 1ps

/*******************************************************************************
 16-bit BCD counter with clock divider.
 
 Inputs:
   clk_i: 1-bit counter clock signal (rising edge triggered)
          clk_i is usually connected to clk_o of a clock divider.
   
   clr_i: 1-bit clock divider clear signal (rising edge triggered)
          clr_i should be mapped to a button.
   
   en_i:  1-bit counter enable signal (active high)
          en_i should be mapped to a switch.
   
   rst_i: 1-bit counter reset signal (rising edge triggered)
          rst_i should be mapped to a button.
 
 Outputs:
   an_o: 4-bit anode control signal
         For Digilent BASYS 3 Artix 7 FPGA Trainer Board:
           - an[3] = AN3 (pin W4) leftmost seven-segment display (MSB).
           - an[2] = AN2 (pin V4)
           - an[1] = AN1 (pin U4)
           - an[0] = AN0 (pin U2) rightmost seven-segment display (LSB).
   
   ca_o: 7-bit cathode control signal
         For Digilent BASYS 3 Artix 7 FPGA Trainer Board:
           - ca_o[6] = CA (pin W7)
           - ca_o[5] = CB (pin W6)
           - ca_o[4] = CC (pin U8)
           - ca_o[3] = CD (pin V8)
           - ca_o[2] = CE (pin U5) 
           - ca_o[1] = CF (pin V5)
           - ca_o[0] = CG (pin U7)
*******************************************************************************/
module bcd_counter_wrapper(
    input        clk_i,
    input        clr_i,
    input        en_i,
    input        rst_i,
    output [3:0] an_o,
    output [6:0] ca_o
    );
    
    wire        cntr_clk_tmp;
    wire        dspl_clk_tmp;
    wire [15:0] cnt_tmp;
    
    // initialize a clock divider to prescale clock from 100 MHz to 1 Hz
    clock_divider #(.PSC(100000000)) cntr_clk_divdr(
        .clk_i(clk_i),
        .clr_i(clr_i),
        .clk_o(cntr_clk_tmp)
    );
    
    // initialize a 16-bit BCD counter
    bcd_counter cntr(
        .clk_i(cntr_clk_tmp),
        .en_i(en_i),
        .rst_i(rst_i),
        .cnt_o(cnt_tmp)
    );
    
    // initialize a clock divider to prescale clock from 100 MHz to 1 kHz
    clock_divider #(.PSC(100000)) dspl_clk_divdr(
        .clk_i(clk_i),
        .clr_i(clr_i),
        .clk_o(dspl_clk_tmp)
    );
    
    // initialize a 4-digit seven-segment display
    seven_segment_display dspl(
        .clk_i(clk_i),
        .clr_i(clr_i),
        .en_i(en_i),
        .dig3_i(cnt_tmp[15:12]),
        .dig2_i(cnt_tmp[11:8]),
        .dig1_i(cnt_tmp[7:4]),
        .dig0_i(cnt_tmp[3:0]),
        .an_o(an_o),
        .ca_o(ca_o)
    );
endmodule
