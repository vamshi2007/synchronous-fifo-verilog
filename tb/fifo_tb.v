`timescale 1ns/1ps

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 8;
    parameter ADDR_WIDTH = 3;

    reg clk;
    reg rst;

    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;

    wire full;
    wire empty;

    integer tests_passed;
    integer tests_failed;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    DUT
    (
        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .rd_en(rd_en),

        .din(din),

        .dout(dout),

        .full(full),
        .empty(empty)
    );

    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial
    begin
        $dumpfile("fifo.vcd");
        $dumpvars(0,fifo_tb);
    end

    task write_fifo;

        input [DATA_WIDTH-1:0] data;

        begin

            @(negedge clk);

            din   = data;
            wr_en = 1;

            @(posedge clk);
            #1
            @(negedge clk);

            wr_en = 0;

            $display("[%0t] WRITE : %h",$time,data);

        end

    endtask

    task read_fifo;

        input [DATA_WIDTH-1:0] expected;

        begin

            @(negedge clk);

            rd_en = 1;

            @(posedge clk);
            #1
            @(negedge clk);

            rd_en = 0;

            #1;

            if(dout == expected)
            begin
                tests_passed = tests_passed + 1;
                $display("[%0t] READ PASS : %h",$time,dout);
            end
            else
            begin
                tests_failed = tests_failed + 1;
                $display("[%0t] READ FAIL : Expected=%h Received=%h",
                         $time,expected,dout);
            end

        end

    endtask

    initial
    begin

        tests_passed = 0;
        tests_failed = 0;

        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        repeat(2) @(posedge clk);

        rst = 0;

        $display("\n======================================");
        $display("      BASIC WRITE TEST");
        $display("======================================");

        write_fifo(8'h11);
        write_fifo(8'h22);
        write_fifo(8'h33);
        write_fifo(8'h44);

        if(empty == 0)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] FIFO is not empty.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] FIFO should not be empty.");
        end

        $display("\n======================================");
        $display("      BASIC READ TEST");
        $display("======================================");

        read_fifo(8'h11);
        read_fifo(8'h22);
        read_fifo(8'h33);
        read_fifo(8'h44);

        if(empty)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] FIFO became empty.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] FIFO should be empty.");
        end

        $display("\n======================================");
        $display("      FILL FIFO TEST");
        $display("======================================");

        write_fifo(8'h01);
        write_fifo(8'h02);
        write_fifo(8'h03);
        write_fifo(8'h04);
        write_fifo(8'h05);
        write_fifo(8'h06);
        write_fifo(8'h07);
        write_fifo(8'h08);

        #1;

        if(full)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] FIFO FULL.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] FIFO should be FULL.");
        end
        
        $display("\n======================================");
        $display("         OVERFLOW TEST");
        $display("======================================");

        write_fifo(8'hAA);

        #1;

        if(full)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] Overflow prevented.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] Overflow test failed.");
        end

        $display("\n======================================");
        $display("      EMPTY FIFO TEST");
        $display("======================================");

        read_fifo(8'h01);
        read_fifo(8'h02);
        read_fifo(8'h03);
        read_fifo(8'h04);
        read_fifo(8'h05);
        read_fifo(8'h06);
        read_fifo(8'h07);
        read_fifo(8'h08);

        if(empty)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] FIFO EMPTY.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] FIFO should be EMPTY.");
        end

        $display("\n======================================");
        $display("        UNDERFLOW TEST");
        $display("======================================");

        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        #1;

        if(empty)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] Underflow prevented.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] Underflow test failed.");
        end

        $display("\n======================================");
        $display("    SIMULTANEOUS READ/WRITE TEST");
        $display("======================================");

        write_fifo(8'h55);
        write_fifo(8'h66);
        write_fifo(8'h77);

        @(posedge clk);

        din   = 8'h88;
        wr_en = 1;
        rd_en = 1;

        @(posedge clk);

        wr_en = 0;
        rd_en = 0;

        #1;

        if(empty == 0)
        begin
            tests_passed = tests_passed + 1;
            $display("[PASS] Simultaneous Read/Write.");
        end
        else
        begin
            tests_failed = tests_failed + 1;
            $display("[FAIL] Simultaneous Read/Write.");
        end

        read_fifo(8'h66);
        read_fifo(8'h77);
        read_fifo(8'h88);

        $display("\n======================================");
        $display("      VERIFICATION SUMMARY");
        $display("======================================");

        $display("Tests Passed : %0d", tests_passed);
        $display("Tests Failed : %0d", tests_failed);

        if(tests_failed == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\nSOME TESTS FAILED");

        $display("======================================");

        #20;
        $finish;

    end

endmodule