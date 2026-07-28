module fifo_memory #

(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = 3
)

(
    input clk,

    input write_en,
    input read_en,

    input [ADDR_WIDTH-1:0] wr_addr,
    input [ADDR_WIDTH-1:0] rd_addr,

    input [DATA_WIDTH-1:0] din,

    output reg [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    always @(posedge clk)
    begin
        if (read_en)
            dout <= memory[rd_addr];

        if (write_en)
            memory[wr_addr] <= din;
    end

endmodule