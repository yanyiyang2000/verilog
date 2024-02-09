`timescale 1ns / 1ps

/*******************************************************************************
 16-bit Johnson counter.
   
 Inputs:
   clk_i: 1-bit counter clock signal (rising edge triggered)
   
   en_i:  1-bit counter enable signal (active high)
          
   rst_i: 1-bit counter reset signal (rising edge triggered)
          
   dir_i: 1-bit counter direction signal. 0 is shift left, 1 is shift right.
   
 Output:
   cnt_o: 16-bit counter count signal
*******************************************************************************/
module johnson_counter(
    input             clk_i,
    input             en_i,
    input             rst_i,
    input             dir_i,
    output reg [15:0] cnt_o
    );
    
    initial begin
        cnt_o = 0;
    end
    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1) begin
            cnt_o <= 0;
        end
        else if (en_i == 1) begin
            if (dir_i == 0) begin // shift left
                cnt_o[15:1] <= cnt_o[14:0];
                cnt_o[0] <= ~cnt_o[15];
            end
            else begin            // shift right
                cnt_o[14:0] <= cnt_o[15:1];
                cnt_o[15] <= ~cnt_o[0];
            end
        end
    end
    
endmodule
