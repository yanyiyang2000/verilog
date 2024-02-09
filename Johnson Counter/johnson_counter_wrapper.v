`timescale 1ns / 1ps

/*******************************************************************************
 16-bit Johnson counter with clock divider.
   
 Inputs:
   clk_i: 1-bit counter clock signal (rising edge triggered)
          clk_i is usually connected to clk_o of a clock divider.
          
   clr_i: 1-bit clock divider clear signal (rising edge triggered)
          clr_i should be mapped to a button.
   
   en_i:  1-bit counter enable signal (active high)
          en_i should be mapped to a switch.
          
   rst_i: 1-bit counter reset signal (rising edge triggered)
          rst_i should be mapped to a button.
          
   dir_i: 1-bit counter direction signal. 0 is shift left, 1 is shift right.
          dir_i should be mapped to a switch.
   
 Output:
   cnt_o: 16-bit counter count signal
          cnt_o can be mapped to LEDs or seven-segment display.
*******************************************************************************/
module johnson_counter_wrapper(
    input         clk_i,
    input         clr_i,
    input         en_i,
    input         rst_i,
    input         dir_i,
    output [15:0] cnt_o
    );
    
    wire clk_tmp;
    
    // initialize a clock divider to prescale clock from 100 MHz to 1 kHz
    clock_divider #(.PSC(100)) clk_divdr (
        .clk_i(clk_i),
        .clr_i(clr_i),
        .clk_o(clk_tmp)
    );
    
    // initialize a 16-bit Johnson counter
    johnson_counter cntr(
        .clk_i(clk_tmp),
        .en_i(en_i),
        .rst_i(rst_i),
        .dir_i(dir_i),
        .cnt_o(cnt_o)
    );
    
endmodule
