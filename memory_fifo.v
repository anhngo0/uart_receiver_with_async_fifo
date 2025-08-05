module memory_fifo
#(parameter ADDRSIZE = 4, 
  parameter DATASIZE = 8) 
(
    input [DATASIZE -1 : 0] wdata,
    input [ADDRSIZE -1: 0] waddr, raddr,
    input wclken, wfull, wclk, wrst,
    output [DATASIZE -1 :0]rdata
);

    // create a ram memory that has 16 entries, each entry has 8 bit
        localparam DEPTH = 1 << ADDRSIZE;
        // reg reset_count = 0;
        reg [DATASIZE - 1 :0] mem [0: DEPTH - 1];

        assign rdata = mem[raddr];
        always @(posedge wclk) begin
            if (wclken && !wfull) begin
                mem[waddr] <= wdata;
                mem[waddr + 1] <= 0;
            end
        end    
    
endmodule