`default_nettype none

module transmitter (
    input clk,
    input rst_n,

    input wr_enb,  // New byte is ready, start transmitting
    input tx_enb,  // Advance to the next bit
    input [7:0] tx_data,  // Byte to transmit

    output reg tx
);

  // 1 start bit, 8 data bits, 1 stop bit

  // Tracks the index of the bit being transmitted.
  reg [2:0] bit_index;

  // Temporary storage of the byte currently being transmitted.
  reg [7:0] tx_reg;

  // Tracks the two ticks needed to complete stop-bit phase
  reg stop_phase;

  typedef enum reg [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
  } state_t;

  state_t state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      tx <= 1;
      bit_index <= 0;
      tx_reg <= 0;
      stop_phase <= 0;

    end else begin

      case (state)

        IDLE: begin
          tx <= 1;
          bit_index <= 0;
          stop_phase <= 0;

          if (wr_enb) begin
            state  <= START;
            tx_reg <= tx_data;
          end
        end

        START: begin
          tx <= 0;

          if (tx_enb) begin
            tx <= tx_reg[0];
            bit_index <= 1;
            state <= DATA;
          end
        end

        DATA: begin
          if (tx_enb) begin
            tx <= tx_reg[bit_index];

            if (bit_index == 7) state <= STOP;
            else bit_index <= bit_index + 1;
          end
        end

        STOP: begin
          if (tx_enb) begin
            if (!stop_phase) begin
              tx <= 1;
              stop_phase <= 1;
            end else begin
              state <= IDLE;
              stop_phase <= 0;
            end
          end
        end

      endcase
    end
  end

endmodule
