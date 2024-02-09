`timescale 1ns / 1ps

/*******************************************************************************
 Clock divider prescales input clock by a factor specified by the parameter.
 
 Note:
   The default prescaler is 100.
   
 Inputs:
   clk_i: 1-bit input clock signal (rising edge triggered)
          For Digilent BASYS 3 Artix 7 FPGA Trainer Board: 
            clk_i = 100 MHz oscillator (pin W5)
        
   clr_i: 1-bit signal to clear current clock cycle count (rising edge triggered)
          clr_i should be mapped to a button.
   
 Output:
   clk_o: 1-bit output clock signal
*******************************************************************************/
module clock_divider #(parameter PSC = 100) (
    input      clk_i,
    input      clr_i,
    output reg clk_o
    );
    
    reg[31:0] cnt_tmp = 32'd0; // current clock cycle count
    
    always @(posedge clk_i or posedge clr_i) begin
        if (clr_i == 1) begin
            cnt_tmp <= 0;
        end
        else if (cnt_tmp == PSC - 1) begin
            cnt_tmp <= 0;
            clk_o   <= 1;
        end 
        else begin
            cnt_tmp <= cnt_tmp + 1;
            clk_o   <= 0;
        end
    end

endmodule
