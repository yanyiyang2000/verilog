`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//  Testbench for SPI master.
//
// Author:
//  Yiyang Yan
//
// Date:
//  2024/04/30
////////////////////////////////////////////////////////////////////////////////
module spi_master_tb(

    );
    
    reg clk;
    reg en;
    wire sclk;
    wire ss;
    wire mosi;
    wire miso;
    
    // initialize a SPI master
    spi_master uut (
        .clk_i(clk),
        .en_i(en),
        .sdi_i(miso),
        .sdo_o(mosi),
        .sclk_o(sclk),
        .ss_o(ss)
    );
    
    // initialize a 100 MHz clock
    always begin
        #5;
        clk = 1'b0;
        #5;
        clk = 1'b1;
    end

    initial begin
        clk <= 1'b1;
        en  <= 1'b0;
        
        #44;
        en <= 1'b1;
    end
endmodule
