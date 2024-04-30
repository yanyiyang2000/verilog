`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//  Testbench for SPI slave.
//
// Author:
//  Yiyang Yan
//
// Date:
//  2024/04/30
////////////////////////////////////////////////////////////////////////////////
module spi_slave_tb(

    );
    
    reg clk;
    reg sclk;
    reg ss;
    reg mosi;
    wire miso;
    
    // initialize a SPI slave
    spi_slave uut(
        .clk_i(clk),
        .sclk_i(sclk),
        .ss_i(ss),
        .sdi_i(mosi),
        .sdo_o(miso)
    );
    
    // initialize a 100 MHz clock (CLK)
    always begin
        #5;
        clk = 0;
        #5;
        clk = 1;
    end
    
    // initialize a 1 MHz clock (SCLK)
    always begin
        #500;
        sclk = 0;
        #500;
        sclk = 1;
    end
    
    initial begin
        ss  = 1'b1; #1000;
        
        ss <= 1'b0; #200000;
        $finish;
    end
endmodule
