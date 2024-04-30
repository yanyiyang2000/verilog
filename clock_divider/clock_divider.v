`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//   Clock divider prescales input clock by a factor specified by the parameter.
//
// Parameter:
//   PSC: factor by which the input clock will be prescaled.
//        The default value is 100.
//
// Inputs:
//   clk_i: 1-bit input clock signal (raising edge triggered)
//
// Output:
//   clk_o: 1-bit output clock signal
//
// Author:
//   Yiyang Yan
//
// Date:
//   2024/03/05
////////////////////////////////////////////////////////////////////////////////
module clock_divider #(parameter PSC = 100) (
    input  clk_i,
    output clk_o
    );
    
    reg        clk_r;         // register holding clock output
    reg [31:0] cnt_r = 32'b0; // register holding clock cycle count
    
    assign clk_o = clk_r;
    
    always @(posedge clk_i) begin
        if (cnt_r == PSC - 1) begin
            cnt_r <= 32'b0;
            clk_r <= 1;
        end 
        else begin
            cnt_r <= cnt_r + 1;
            clk_r <= 0;
        end
    end
    
endmodule
