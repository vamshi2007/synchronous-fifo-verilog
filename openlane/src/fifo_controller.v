module fifo_controller #

(
    parameter DEPTH = 8,
    parameter ADDR_WIDTH = 3
)

(
    input clk,
    input rst,

    input wr_en,
    input rd_en,

    output reg [ADDR_WIDTH-1:0] wr_ptr,
    output reg [ADDR_WIDTH-1:0] rd_ptr,

    output full,
    output empty,

    output write_en,
    output read_en
);

    reg [ADDR_WIDTH:0] count;

    assign empty = (count == 0);
    assign full = (count == DEPTH);

    assign write_en = wr_en && !full;
    assign read_en = rd_en && !empty;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            wr_ptr <= 0;
        else if (write_en)
        begin
            if (wr_ptr == DEPTH-1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr + 1;
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            rd_ptr <= 0;
        else if (read_en)
        begin
            if (rd_ptr == DEPTH-1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr + 1;
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            count <= 0;
        else
        begin
            case ({write_en, read_en})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                2'b11: count <= count;
                default: count <= count;
            endcase
        end
    end

endmodule