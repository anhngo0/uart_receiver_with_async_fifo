
module fifo_top 
#(parameter DATASIZE = 8,
  parameter ASIZE = 4)
(
    input [DATASIZE - 1: 0] wdata,
    input winc, wclk, wrst,
    input rinc, rclk, rrst ,
    output [DATASIZE - 1 : 0] rdata,
    output wfull, rempty  
);
    wire [ASIZE - 1:0] waddr, raddr;
    wire [ASIZE : 0] wptr, rptr; 
    reg [ASIZE : 0] wq2_rptr = 0, rq2_wptr = 0, r_sync = 0, w_sync = 0;

    always @(posedge rclk or posedge rrst) begin
        if(rrst) {rq2_wptr, r_sync} <= 0;
        else {rq2_wptr, r_sync} <= {r_sync, wptr};
    end

    always @(posedge wclk or posedge wrst) begin
        if(wrst) {wq2_rptr, w_sync} <= 0;
        else {wq2_rptr, w_sync} <= {w_sync, rptr};
    end
    // sync_with_ff #(ASIZE) sync_w2r(.Q(rq2_wptr), .D(wptr),
    //                   .clk(rclk), .rst(rrst));
    // sync_with_ff #(ASIZE) sync_r2w(.Q(wq2_rptr), .D(rptr),
    //                   .clk(wclk), .rst(wrst));

      memory_fifo #( ASIZE,DATASIZE) fifomem 
    (.rdata(rdata), .wdata(wdata), .waddr(waddr), .raddr(raddr),
    .wclken(winc), .wfull(wfull), .wclk(wclk), .wrst(wrst));

    empty_rptr_fifo #(ASIZE) rptr_empty
    (.rempty(rempty), .raddr(raddr), 
    .rptr(rptr),.rq2_wptr(rq2_wptr),
    .rinc(rinc), .rclk(rclk), .rrst(rrst));

     full_wptr_fifo #(ASIZE) wptr_full
     (.wfull(wfull), .waddr(waddr), .wptr(wptr), .wq2_rptr(wq2_rptr),
      .winc(winc), .wclk(wclk), .wrst(wrst));
    

   
endmodule