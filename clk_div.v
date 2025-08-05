
module clk_div 
#(parameter OLD_CLKS_PER_NEW_CLKS = 1)
(
    input clk,
    output div_clk
);
    localparam CNT_WIDTH = 17;
    reg [CNT_WIDTH -1 :0] count = 0;
    reg reg_clk = 1'b0;

    always @(posedge clk) begin
        if(count == OLD_CLKS_PER_NEW_CLKS - 1) begin
            count <= 0;
            reg_clk <= ~reg_clk;
        end
        else begin
            count <= count + 1;
        end 
    end

    assign div_clk = reg_clk;
endmodule
