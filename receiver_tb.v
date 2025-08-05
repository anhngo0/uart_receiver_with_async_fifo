`timescale 1ns/1ps

module uart_receiver_tb;
    parameter BAUD_PERIOD = 8680; // 8.68 us in ns
    
    reg clk = 0;
    reg rst = 0;
    reg RxBit = 1; // Idle line is high
    wire [6:0] sseg;

    // Instantiate the DUT
    uart_receiver_top uut (
        .RxBit(RxBit),
        .clk(clk),
        .rst(rst),
        .sseg(sseg)
    );

    // 27 MHz clock (period ≈ 37.037 ns)
    always #18.5 clk = ~clk;

    // Task to send a UART byte
    task send_uart_byte(input [7:0] byte);
        integer i;
        begin
            RxBit = 0; // Start bit
            #BAUD_PERIOD; // 1 baud period * 16 samples

            for (i = 0; i < 8; i = i + 1) begin
                RxBit = byte[i];
                #BAUD_PERIOD; // Send each bit
            end

            RxBit = 1; // Stop bit
            #BAUD_PERIOD; // End of frame
        end
    endtask

    initial begin
        // Generate reset pulse
        rst = 1;
        #(1000);
        rst = 0;

        // Wait a bit
        #(1000);

        // Send character '5' (ASCII 53 or 0x35)
        send_uart_byte(8'd53);

        // Wait and send another character (e.g., '8')
        #(30000);
        send_uart_byte(8'd56);

        #(100000);
        $finish;
    end

    initial begin
        $dumpfile("uart_receiver.vcd");
        $dumpvars(0, uart_receiver_tb);
    end

endmodule
