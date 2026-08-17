`default_nettype none

module receiver (
    input clk,
    input rst_n,

    input rx_enb,  // rx baud tick 
    input rx,

    output reg rx_sync,
    output reg [7:0] rx_data,
    output reg rx_valid
);


  typedef enum reg [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
  } state_t;

  state_t state;

  // Detects the start bit
  reg rx_prev;
  wire falling_edge = (rx_prev == 1'b1) && (rx == 1'b0);

  // Tracks the index of the bit being sampled
  reg [3:0] bit_index;

  // Counts the 16 sampling ticks to collect data at tick 8
  reg [3:0] rx_counter;

  // Stores the received byte until the stop bit is validated.
  reg [7:0] shift_reg;


  always @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      rx_valid <= 0;
      rx_data <= 0;
      shift_reg <= 0;
      rx_sync <= 0;
      bit_index <= 0;
      rx_counter <= 0;
      rx_prev <= 1'b1;



    end else begin
      rx_prev <= rx;

      case (state)

        IDLE: begin
          shift_reg <= 0;
          rx_valid  <= 0;


          if (falling_edge) begin
            rx_sync <= 1;
            state   <= START;
          end
        end

        START: begin
          bit_index <= 0;
          rx_sync <= 0;
          rx_counter <= 0;


          if (rx_enb) state <= DATA;

        end

        DATA: begin

          if (rx_enb) begin
            if (bit_index < 9) begin
              rx_counter <= rx_counter + 1;


              if (rx_counter == 8 & bit_index > 0) begin
                shift_reg[bit_index-1] <= rx;
              end

              if (bit_index == 8) begin
                shift_reg[bit_index-1] <= rx;
                rx_valid <= 0;
                state <= STOP;
              end


              if (rx_counter == 15) begin
                rx_counter <= 0;
                bit_index  <= bit_index + 1;
              end
            end

          end
        end

        STOP: begin
          if (rx && rx_enb) begin
            rx_data <= shift_reg;
            rx_valid <= 1;
            state <= IDLE;
          end
        end

      endcase
    end
  end


endmodule
