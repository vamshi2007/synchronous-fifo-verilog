module fifo #

(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = 3
)

(
    input clk,
    input rst,

    input wr_en,
    input rd_en,

    input  [DATA_WIDTH-1:0] din,

    output [DATA_WIDTH-1:0] dout,

    output full,
    output empty
);

    wire write_en;
    wire read_en;

    wire [ADDR_WIDTH-1:0] wr_ptr;
    wire [ADDR_WIDTH-1:0] rd_ptr;

    fifo_controller #

    (
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )

    controller

    (
        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .rd_en(rd_en),

        .wr_ptr(wr_ptr),
        .rd_ptr(rd_ptr),

        .full(full),
        .empty(empty),

        .write_en(write_en),
        .read_en(read_en)
    );

    fifo_memory #

    (
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )

    memory

    (
        .clk(clk),

        .write_en(write_en),
        .read_en(read_en),

        .wr_addr(wr_ptr),
        .rd_addr(rd_ptr),

        .din(din),

        .dout(dout)
    );

endmodule