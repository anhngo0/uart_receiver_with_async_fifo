
module btn_debounce (
    input clk, input sig_input, 
    output sig_output 
);
    reg  Q1 = 0, Q2 = 0;
    always @(posedge clk) begin
        {Q2, Q1} <= {Q1, sig_input};
    end

    assign sig_output = Q1 & (~Q2);

endmodule