`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//   Non-programmable SPI slave.
//
// Note:
//   The SPI slave operates under mode 0 (CPOL = 0, CPHA = 0).
//   - CPOL = 0: SCLK signal is active high.
//   - CPHA = 0: Data is sampled at the rising edge of SCLK signal.
//   The most significant bit (MSb) is sent first.
//
// Inputs:
//   clk_i:  1-bit input clock signal (rising edge triggered)
//           clk_i must be at least 2 times faster than the SCLK signal
//
//   sclk_i: 1-bit SPI SCLK signal (active high, rising edge triggered)
//
//   ss_i:   1-bit SPI SS signal (active low)
//
//   sdi_i:  1-bit SPI MOSI signal
//
// Outputs:
//   sdo_o:  1-bit SPI MISO signal
//
// Author:
//   Yiyang Yan
//
// Date:
//   2024/04/30
////////////////////////////////////////////////////////////////////////////////
module spi_slave(
    input  clk_i,
    input  sclk_i,
    input  ss_i,
    input  sdi_i,
    output sdo_o
    );
    
    reg [1:0] sclk_r;           // LEFT-shift register holding previous and current SCLK values to detect the raising/falling egdes of SCLK
    reg [1:0] ss_r;             // LEFT-shift register holding previous and current SCLK values to detect the raising/falling egdes of SS
    reg       en_r;             // register specifying if the slave is selected
    
    reg [7:0] buffer_r [0:3];   // register holding the BYTEs to be transmitted on MISO
    reg [2:0] cnt_r;            // register holding the count of BITs transmitted
    reg [1:0] idx_r;            // register holding the index of BYTE to be transmitted
    reg [7:0] tx_byte_r;        // fifo holding the BYTE to be transmitted on MISO
    reg [7:0] rx_byte_r;        // fifo holding the BYTE to be received on MOSI
    
    assign sdi_i = rx_byte_r[7];
    assign sdo_o = tx_byte_r[7];
    
    initial begin
        buffer_r[0] = 8'h00;
        buffer_r[1] = 8'h11;
        buffer_r[2] = 8'h22;
        buffer_r[3] = 8'h33;        
    end
    
    initial begin
        en_r      = 1'b0;
        cnt_r     = 3'b000;
        idx_r     = 2'b00;
        tx_byte_r = buffer_r[idx_r];
        rx_byte_r = 8'bXXXXXXXX;
    end
    
    // synchronize all signals
    always @(posedge clk_i) begin
        // LEFT-shift ss_r, add the current value of SS to the right
        ss_r <= {ss_r[0], ss_i};
        
        // detect the falling and raising edge of SS
        // note: only slave detects the falling and raising edge of SS
        if (ss_r == 2'b10) begin
            en_r <= 1'b1;
        end 
        else if (ss_r == 2'b01) begin
            en_r  <= 1'b0;
            cnt_r <= 3'b000;
        end
        
        if (en_r == 1'b1) begin
            // LEFT-shift sclk_r, add the current value of SCLK to the right
            sclk_r <= {sclk_r[0], sclk_i};
            
            // detect the falling edge of SCLK
            // note: both master and slave detects the rising/falling edge of SCLK
            // note: for mode 0 and 2, shift out bits at falling edge (since data is sampled at rising edge)
            //       for mode 1 and 3, shift out bits at rising edge
            // note: to detect the rising edge, use sclk_r == 2'b01
            if (sclk_r == 2'b10) begin
                // tramsmit the MSb first, LEFT-shift and wrap around tx_byte_r
                tx_byte_r <= {tx_byte_r[6:0], tx_byte_r[7]};
                
                // receive the MSb first, LEFT-shift and wrap around rx_byte_r
                rx_byte_r <= {rx_byte_r[6:0], rx_byte_r[7]};
                
                // increment bit count and byte index
                cnt_r <= cnt_r + 1;
                if (cnt_r == 3'b111) begin
                    cnt_r     <= 3'b000;
                    idx_r     <= (idx_r + 1) % 4;
                    tx_byte_r <= buffer_r[(idx_r + 1) % 4];
                end
            end
        end
    end
    
endmodule
