
module uart_receiver 
#(parameter BAUD_RATE = 115200) 
// clock freq = baud rate * #_of_samples_per_bit
//            = _transmitted_samples_per_seconds
(
    input RxBit,
    input clk,
    input rst,
    output reg [7:0] RxData,
    output rx_done_signal // transmitt 10 bits done or not
);
    localparam IDLE = 0, RECEIVING = 1;
    localparam integer SAMPLE = 16; // # samples per bit
    // uart cell: 1-bit start, 8-bit data, 1-bit end
     localparam integer UART_CELL_TOTAL_BITS = 10;
     
    reg [3:0] sample_counter = 0;// count sample to detect start bit and assign data 
    reg [3:0] baud_counter = 0; // count baud to detect the number of transmitted bits

    reg[9:0] rx_total_bits_reg = 0;// assign input bit into this var
    reg state = 0;
    reg rx_done = 0;     
   
    assign rx_done_signal = rx_done;

    always @(posedge clk) begin

        //reset logic
        if(rst) begin
            state <= 0;
            rx_total_bits_reg <= 0;
            sample_counter <= 0;
            baud_counter <= 0;
            rx_done <= 0;
            RxData <= 0;
        end else begin
        // state machine
        case (state)
            IDLE: begin
                if(rx_done) rx_done <= 0;
                //if RxBit is low for haft a baud then change state
                if(~RxBit) begin
                    sample_counter <= sample_counter + 1;
                end

                //if input is 0 after half a baud, detect it as a start bit
                if(~RxBit && sample_counter == SAMPLE / 2 - 1) begin
                    state <= RECEIVING;
                end

            end 

            RECEIVING: begin
                
                //shift data
                if (sample_counter == SAMPLE / 2 - 1) begin
                    rx_total_bits_reg <= {RxBit, rx_total_bits_reg[9:1]};
                end
                
                // return to idle state after receiving uart_cell_total - 1 = 9bit (8 bit data, 1 bit end)
                if(sample_counter == SAMPLE - 1 & baud_counter == UART_CELL_TOTAL_BITS - 1) begin
                        state <= IDLE;
                        sample_counter <= 0;
                        baud_counter <= 0;
                        RxData <= rx_total_bits_reg[8:1];
                        rx_done <= 1;
                        rx_total_bits_reg <= 0;
                end else if(sample_counter == SAMPLE - 1) begin
                    //baud counter
                    baud_counter <= baud_counter + 1;
                    sample_counter <= 0;      
                end else 
                    //sample counter
                    sample_counter <= sample_counter + 1; 
            end
        endcase        
        end
    end

endmodule
