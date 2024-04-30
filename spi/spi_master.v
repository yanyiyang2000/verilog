`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Description:
//   Non-programmable SPI master.
//
// Note:
//   The SPI master operates under mode 0 (CPOL = 0, CPHA = 0).
//   - CPOL = 0: SCLK signal is active high.
//   - CPHA = 0: Data is sampled at the rising edge of SCLK signal.
//   The most significant bit (MSb) is sent first.
//
// Inputs:
//   clk_i:  1-bit clock signal (rising edge triggered)
//           clk_i must be at least 2 times faster than the SCLK signal
//
//   en_i:   1-bit SPI master enable signal (active high)
//
//   sdi_i:  1-bit SPI MISO signal
//
// Outputs:
//   sdo_o:  1-bit SPI MOSI signal
//
//   sclk_o: 1-bit SPI SCLK signal (active high, rising edge triggered)
//
//   ss_o:   1-bit SPI SS signal (active low)
//
// Author:
//   Yiyang Yan
//
// Date:
//   2024/04/30
////////////////////////////////////////////////////////////////////////////////
module spi_master(
    input  clk_i,
    input  en_i,
    input  sdi_i,
    output sdo_o,
    output sclk_o,
    output ss_o
    );
    
    reg [1:0] sclk_r;     // LEFT-shift register holding previous and current SCLK values to detect the raising/falling egdes of SCLK
    reg       ss_r;       // register holding current value of SS
    
    reg [7:0] tx_byte_r;  // fifo holding the BYTE to be transmitted on MOSI
    reg       tx_bit_r;   // register holding the current BIT to be transmitted on MOSI
    reg [7:0] rx_byte_r;  // fifo holding the BYTE to be received on MISO
    reg       rx_bit_r;   // register holding the current BIT to be received on MISO
    
    assign sclk_o = sclk_r[0]; // sclk_o always gets the current SCLK value in sclk_r
    assign ss_o   = ss_r;
    assign sdo_o  = tx_bit_r;
    assign sdi_i  = rx_bit_r;
    
    initial begin
        sclk_r     = 2'b00;
        ss_r       = 1'b1;
        tx_byte_r  = 8'b11001010; // for testing
        tx_bit_r   = 1'bX;
        rx_byte_r  = 8'bXXXXXXXX;
        tx_bit_r   = 8'bX;
    end
    
    // synchronize all signals
    always @(posedge clk_i) begin
        if (en_i == 1) begin
            // LEFT-shift sclk_r, invert the shifted-out value and add it back to the right
            sclk_r <= {sclk_r[0], ~sclk_r[1]};
            
            // note: only slave detects the raising/falling edge of SS
            ss_r <= 0;
            
            // detect the raising edge of SCLK
            // note: both master and slave detects the raising/falling edge of SCLK
            // note: if to detect the falling edge, use sclk_r == 2'b10
            if (sclk_r == 2'b01) begin
                // transmit the MSb first, LEFT-shift and wrap around tx_byte_r
                tx_bit_r  <= tx_byte_r[7];
                tx_byte_r <= {tx_byte_r[6:0], tx_byte_r[7]};
                
                // receive the MSb first, LEFT-shift and wrap around rx_byte_r
                rx_byte_r <= {rx_byte_r[6:0], rx_bit_r};
            end
        end 
        else begin 
            ss_r <= 1;
        end
    end
endmodule
