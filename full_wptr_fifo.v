module full_wptr_fifo #(parameter ADDRSIZE = 4) (
    input [ADDRSIZE : 0] wq2_rptr,
    input winc, wclk, wrst,
    output [ADDRSIZE : 0] wptr,
    output wfull,
    output [ADDRSIZE - 1 : 0] waddr  
);
    reg [ADDRSIZE:0] wbin = 0;
    reg [ADDRSIZE:0] wptr_value = 0;
    wire [ADDRSIZE:0] wgraynext, wbinnext;
    reg wfull_val = 0;

    assign wfull = wfull_val;
    assign wptr = wptr_value;
    assign waddr = wbin[ADDRSIZE-1 : 0];
    assign wbinnext = wbin + (winc & ~wfull_val);

    // binary to gray
    assign wgraynext = wbinnext ^ (wbinnext >> 1);

  //GRAYSTYLE #2 pointer
    always @(posedge wclk or posedge wrst) begin
        if(wrst) {wbin, wptr_value} <= 0;
        else {wbin, wptr_value} <= {wbinnext, wgraynext};
    end

    always @(posedge wclk or posedge wrst) begin
        if(wrst) wfull_val <= 1'b0;
    // full flag logic
        else 
            wfull_val <= (wgraynext == {!wq2_rptr[ADDRSIZE: ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});
    end
    
endmodule