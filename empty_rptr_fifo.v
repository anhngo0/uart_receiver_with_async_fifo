module empty_rptr_fifo #(parameter ADDRSIZE = 4)(
    input [ADDRSIZE:0] rq2_wptr,
    input rinc, rclk, rrst,
    output [ADDRSIZE:0] rptr,
    output rempty,
    output [ADDRSIZE-1 : 0] raddr  
);
    reg [ADDRSIZE:0] rptr_value = 0;
    reg [ADDRSIZE : 0] rbin = 0;
    wire [ADDRSIZE : 0] rbinnext, rgraynext;

    assign rptr = rptr_value;
    
    assign raddr = rbin [ADDRSIZE - 1 : 0];

    assign rgraynext = rbin ^ (rbin >> 1);  
    assign rempty = (rgraynext == rq2_wptr);
    assign rbinnext = rbin + (rinc & ~rempty);
   
    always @(posedge rclk or posedge rrst) begin
        if(rrst) {rptr_value, rbin} <= 0;
        else {rptr_value, rbin} <= {rgraynext, rbinnext};
    end 

endmodule