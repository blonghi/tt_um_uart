/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_uart (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // X IOs: Input path
    output wire [7:0] uio_out,  // X IOs: Output path
    output wire [7:0] uio_oe,   // X IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // X always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  
  wire tx_enb;
  wire [7:0] tx_data = ui_in;

  wire rx_enb;
  wire rx_sync;
  wire [7:0] rx_data;
  wire rx_valid;

  // list all unused inputs to prevent warnings
  wire _unused = &{uio_in[7:2], ena};

  // uio[1:0] = input (wr_enb, rx), uio[7:2] = output (rx_data)
  assign uio_oe = 8'b1111_1100;

  // rx_data split: uio can't carry all 8 bits since uio[1:0] are reserved
  // as inputs (wr_enb, rx) see README pin table for full pin map
  assign uio_out[7:2] = rx_data[7:2];
  assign uo_out[3:2]  = rx_data[1:0];

  wire wr_enb = uio_in[0];





  baud_rate_gen u_baudrate_generator (
    //inputs
    .clk(clk),
    .rst_n(rst_n),
    .rx_sync(rx_sync),

    //outputs
    .rx_enb(rx_enb),
    .tx_enb(tx_enb)
  );

    transmitter u_transmitter (
    //inputs 
    .clk(clk), 
    .rst_n(rst_n), 
    .wr_enb(wr_enb),
    .tx_enb(tx_enb),
    .tx_data(tx_data),

    //outputs
    .tx(uo_out[0])
  );

  receiver u_receiver (
    // inputs
    .clk(clk), 
    .rst_n(rst_n), 
    .rx_enb(rx_enb),
    .rx(uio_in[1]),

    //outputs
    .rx_sync(rx_sync),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  assign uo_out[1]   = rx_valid;

  //unused pins
  assign uo_out[7:4] = 4'b0; 
  assign uio_out[1:0] = 2'b0;  

endmodule
