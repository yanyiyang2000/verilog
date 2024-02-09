`timescale 1ns / 1ps

/*******************************************************************************
 16-bit BCD counter.
 
 Inputs:
   clk_i: 1-bit counter clock signal (rising edge triggered)
   
   en_i:  1-bit counter enable signal (active high)
   
   rst_i: 1-bit counter reset signal (rising edge triggered)
 
 Outputs:
   cnt_o: 16-bit counter count signal
*******************************************************************************/
module bcd_counter(
    input             clk_i, // clock signal
    input             en_i,  // counter enable signal
    input             rst_i, // counter reset signal
    output reg [15:0] cnt_o  // counter output signal
    );
    
    initial begin
        cnt_o <= 16'b0;
    end
    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1) begin
            cnt_o <= 16'b0;
        end
        else if (en_i == 1) begin
            if (cnt_o[3:0] == 4'b1001) begin               // counter reaches XXX9
                cnt_o[3:0] <= 4'b0000;
                if (cnt_o[7:4] == 4'b1001) begin           // counter reaches XX99
                    cnt_o[7:4] <= 4'b0000;
                    if (cnt_o[11:8] == 4'b1001) begin      // counter reaches X999
                        cnt_o[11:8] <= 4'b0000;
                        if (cnt_o[15:12] == 4'b1001) begin // counter reaches 9999
                            cnt_o[15:12] <= 4'b0000;
                        end else
                            cnt_o[15:12] <= cnt_o[15:12] + 1;
                    end else
                        cnt_o[11:8] <= cnt_o[11:8] + 1;
                end else
                    cnt_o[7:4] <= cnt_o[7:4] + 1;
            end else
                cnt_o[3:0] <= cnt_o[3:0] + 1;
        end
    end
    
endmodule
