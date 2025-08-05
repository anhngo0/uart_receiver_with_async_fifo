module sync_with_ff 
#(parameter ADDRSIZE = 4) (
    input clk, rst,
    input [ADDRSIZE :0] D,
    output [ADDRSIZE:0] Q
);
    reg [ADDRSIZE:0] sync, Q_reg;
    assign Q = Q_reg;
    always @(posedge clk or posedge rst) begin
        if(rst) {Q_reg, sync} <= 0;
        else {Q_reg, sync} <= {sync, D};
    end
endmodule