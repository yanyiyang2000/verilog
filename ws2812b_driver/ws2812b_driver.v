`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//   WS2812B driver.
//
// Note:
//   The driver will display one LED at a time on the WS2812B panel from bottom 
//   to top. 
//   The least significant bit (LSb) is sent first.
//
// Parameter:
//   NUM_LED: number of LEDs on the WS2812B panel.
//
// Inputs:
//   clk_i: 1-bit clock signal (rising edge triggered)
//          clk_i should be connected to a 100 MHz clock source
//
// Output:
//   bit_o: 1-bit data signal for WS2812B
//
// Author:
//   Yiyang Yan
//
// Date:
//   2024/04/30
////////////////////////////////////////////////////////////////////////////////
module ws2812b_driver #(
    parameter NUM_LED = 768
    )(
    input         clk_i, // 100 MHz clock, 10 ns / cycle
    output        bit_o
    );
    
    reg [15:0] addr_r;          // register holding current byte memory address
    reg [15:0] bytes_r[255:0];  // register holding bytes to send
    reg        bit_r;           // register holding current bit to send
    reg [7:0]  byte_r;          // register holding current byte to send
    reg [15:0] clk_cnt_r;       // register holding current count of clock cycles
    reg [3:0]  bit_cnt_r;       // register holding current count of bits sent
    reg [9:0]  byte_cnt_r;      // register holding current count of bytes sent
    reg [15:0] frame_cnt_r;     // register holding current count of frames
    reg [1:0]  state_r;         // register holding current state
   
    assign bit_o  = bit_r;
    
    initial begin
        bit_r       <= 1'b0;
        byte_r      <= 8'hXX; 
        clk_cnt_r   <= 16'd0;
        bit_cnt_r   <= 4'd0;
        byte_cnt_r  <= 10'd1;
        frame_cnt_r <= 16'd1;
        state_r     <= 2'b00;
    end
    
    initial begin
        for (integer i = 0; i < 256; i = i + 1) begin
            bytes_r[i] = 8'h00;
        end
        
        bytes_r[ 3 * (NUM_LED - 1) ]     <= 8'hFF;
        bytes_r[ 3 * (NUM_LED - 1) + 1 ] <= 8'hFF;
        bytes_r[ 3 * (NUM_LED - 1) + 2 ] <= 8'hFF;
        
        addr_r <= 16'h0000;
    end
    
    always @(posedge clk_i) begin
        case (state_r)
            2'b00: begin                                        // STATE 0: reset (TL = 50000 ns or 50 us)
                if (clk_cnt_r == 5000) begin                        // reset complete, transition to STATE 1
                    clk_cnt_r <= 16'd0;
                    byte_r    <= bytes_r[addr_r];
                    addr_r    <= addr_r + 1;
                    state_r   <= 2'b01;
                end
                else begin                                          // TL in progress
                    clk_cnt_r <= clk_cnt_r + 1;
                    state_r   <= 2'b00;
                end
            end
            
            2'b01: begin                                        // STATE 1: schedule bit transmission
                if (bit_cnt_r == 4'd8) begin                        // a byte is transmitted
                    if (byte_cnt_r == 3 * NUM_LED) begin                // all packets have been transmitted, transition to STATE 0
                        if (frame_cnt_r == 3000) begin                      // all frames have been displayed 
                            addr_r      <= (addr_r + 3) % (3 * NUM_LED);
                            frame_cnt_r <= 16'd1;
                        end
                        else begin                                          // frame display in progress
                            addr_r      <= addr_r - 3 * NUM_LED;
                            frame_cnt_r <= frame_cnt_r + 1;
                        end
                        
                        bit_cnt_r  <= 4'd0;
                        byte_cnt_r <= 10'd1;
                        state_r    <= 2'b00;
                    end
                    else begin                                          // packet transmission in progress, load a new byte
                        byte_r     <= bytes_r[addr_r];
                        addr_r     <= addr_r + 1;
                        bit_cnt_r  <= 4'd0;
                        byte_cnt_r <= byte_cnt_r + 1;
                        state_r    <= 2'b01;
                    end
                end
                else begin                                              // byte transmission in progress
                    if (byte_r[bit_cnt_r] == 1'b0) begin                    // transition to STATE 2 to transmit a 0
                        state_r <= 2'b10;
                    end
                    else begin                                              // transition to STATE 3 to transmit a 1
                        state_r <= 2'b11;
                    end
                end
            end
            
            2'b10: begin                                        // STATE 2: bit (0) transmission (TH = 400 ns, TL = 850 ns)
                if (clk_cnt_r < 40) begin                           // TH in progress
                    bit_r     <= 1'b1;
                    clk_cnt_r <= clk_cnt_r + 1;
                end
                else if (clk_cnt_r >= 40 && clk_cnt_r < 125) begin  // TL in progress
                    bit_r     <= 1'b0;
                    clk_cnt_r <= clk_cnt_r + 1;
                end
                else if (clk_cnt_r == 125) begin                    // transmisiion complete, transition to STATE 1
                    clk_cnt_r <= 16'd0;
                    bit_cnt_r <= bit_cnt_r + 1;
                    state_r   <= 2'b01;
                end
            end
            
            2'b11: begin                                        // STATE 3: bit (1) transmission (TH = 800 ns, TH = 450 ns)
                if (clk_cnt_r < 80) begin                           // TH in progress
                    bit_r     <= 1'b1;
                    clk_cnt_r <= clk_cnt_r + 1;
                end
                else if (clk_cnt_r >= 80 && clk_cnt_r < 125) begin  // TL in progress
                    bit_r     <= 1'b0;
                    clk_cnt_r <= clk_cnt_r + 1;
                end
                else if (clk_cnt_r == 125) begin                    // transmisiion complete, transition to STATE 1
                    clk_cnt_r <= 16'd0;
                    bit_cnt_r <= bit_cnt_r + 1;
                    state_r   <= 2'b01;
                end
            end
        endcase
    end
    
endmodule
