`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//  Testbench for WS2812B driver.
//
// Author:
//  Yiyang Yan
//
// Date:
//  2024/04/30
////////////////////////////////////////////////////////////////////////////////
module ws2812b_driver_tb(

    );
    reg  clk_r;
    wire bit_w;
    
    // initialize WS2812B driver
    ws2812b_driver #(3) uut(
        .clk_i(clk_r),
        .bit_o(bit_w)
    );
    
    // initialize a 100 MHz clock
    always begin
        clk_r <= 1'b1;
        #5;
        clk_r <= 1'b0;
        #5;
    end
    
    initial begin
    end
endmodule
