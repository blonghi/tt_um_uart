`default_nettype none

module baud_rate_gen (
    input clk,
    input rst_n,
    input rx_sync,
    input tx_sync,
    output wire tx_enb,
    output wire rx_enb
);

// Timing assumptions:
//      Clock: 49.152 MHz
//      Baud: 9600 bits/second 
//      TX: 5120 cycles/bit (49.152 MHz / 9600)
//      RX: 320 cycles/RX tick (5120 / 16 = 320)

  reg [12:0] tx_counter;
  reg [12:0] rx_counter;


// 16x oversampling, we sample rx at 8th sample to account for timing asymmetry

  always @(posedge clk) begin
    if (!rst_n || rx_sync) rx_counter <= 0;
    else if (rx_counter == 319) rx_counter <= 0;
    else rx_counter <= rx_counter + 1'b1;
  end

  always @(posedge clk) begin
    if (!rst_n || tx_sync) tx_counter <= 0;
    else if (tx_counter == 5119) tx_counter <= 0;
    else tx_counter <= tx_counter + 1'b1;
  end

  assign tx_enb = (tx_counter == 5119) ? 1'b1 : 1'b0;
  assign rx_enb = (rx_counter == 159) ? 1'b1 : 1'b0;

endmodule
