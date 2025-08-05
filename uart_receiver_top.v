module uart_receiver_top 
#( parameter BAUD_RATE = 115200, SAMPLE = 16, CLK_FREQ = 27000000)
(
    input RxBit,
    input clk,
    input rst,
    output reg [6:0] sseg //7-segment output
);
    localparam CLKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * SAMPLE * 2);
    wire [7:0] rx_data;
    wire syncRxBit;
    wire transmission_done_signal;
    wire sample_clk;
    wire [7:0] fifo_output;
    reg [7:0] display_digit; // display value
    wire full_fifo_signal, empty_fifo_signal;
    
    //mechanical button needs at least 3ms to be stable
    //in here, i divide clock freq 108000 times -> 1 cycle = 4ms
    wire press_btn_clk;
    wire rst_after_debounce; // in clk after dividing
    wire rst_in_fpga_clk;    // one pulse in fpga clk
    wire rst_in_baud_rate;   // one pulse in baud rate
    
    //debounce button
    clk_div #(108000) btn_clk_div(clk, press_btn_clk);
    btn_debounce btn_debounce(
        .clk(press_btn_clk), 
        .sig_input(rst), 
        .sig_output(rst_after_debounce)
    );
    
    // get one pulse reset in fpga clk
    btn_debounce one_pulse_reset_fpga_clk(
        .clk(clk), 
        .sig_input(rst_after_debounce), 
        .sig_output(rst_in_fpga_clk)
    );

    //get one pulse reset at baud rate
    clk_div #(CLKS_PER_SAMPLE) sample_clk_div(clk, sample_clk);
    btn_debounce one_pulse_reset_baud (
         .clk(sample_clk),
         .sig_input(rst_after_debounce),
         .sig_output(rst_in_baud_rate)
    );
    sync_with_ff #(0) sync_input(sample_clk, rst_in_baud_rate, RxBit, syncRxBit);
    uart_receiver #(BAUD_RATE) uart_receiver(
        .clk(sample_clk),
        .rst(rst_in_baud_rate),
        .RxBit( syncRxBit),
        .RxData(rx_data),
        .rx_done_signal(transmission_done_signal)
    );
    
    fifo_top fifo_top(
        .wclk(sample_clk), .wrst(rst_in_baud_rate), .winc(transmission_done_signal),
        .rclk(clk), .rrst(rst_in_fpga_clk), .rinc(1'b1),
        .wdata(rx_data), .rdata(fifo_output), 
        .wfull(full_fifo_signal), .rempty(empty_fifo_signal)
    );

    always @(posedge clk) begin
        if(fifo_output) display_digit <= fifo_output;
//        case (rx_data[3:0])
        case (display_digit - "0")
            4'h0: sseg <= 7'b1000000;
            4'h1: sseg <= 7'b1111001;
            4'h2: sseg <= 7'b0100100;
            4'h3: sseg <= 7'b0110000;
            4'h4: sseg <= 7'b0011001;
            4'h5: sseg <= 7'b0010010;
            4'h6: sseg <= 7'b0000010;
            4'h7: sseg <= 7'b1111000;
            4'h8: sseg <= 7'b0000000;
            4'h9: sseg <= 7'b0010000;
//            4'hA: sseg <= 7'b0001000;
//            4'hB: sseg <= 7'b0000011;
//            4'hC: sseg <= 7'b1000110;
//            4'hD: sseg <= 7'b0100001;
//            4'hE: sseg <= 7'b0000110;
//            4'hF: sseg <= 7'b0001110;
            default: sseg <= 7'b1000000;
        endcase
    end
endmodule