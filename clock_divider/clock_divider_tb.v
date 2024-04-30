`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//  Testbench for clock divider.
//
// Author:
//  Yiyang Yan
//
// Date:
//  2024/03/05
////////////////////////////////////////////////////////////////////////////////
module clock_divider_tb(
    );
    
    reg  clk_r;
    wire clk_w;
    
    // initialize a clock divider with prescaler 100
    clock_divider #(.PSC(100)) uut(
        .clk_i(clk_r),
        .clk_o(clk_w)
    );
    
    // initialize a 100 MHz clock input
    always begin
        clk_r = 1'b0;
        #5;
        clk_r = 1'b1;
        #5;
    end
    
    // run for 10 us
    initial begin
        #10000;
        $finish;
    end
    
endmodule
