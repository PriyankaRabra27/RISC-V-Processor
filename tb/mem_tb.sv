`timescale 1ns/1ps

module mem_tb;

    logic i_clk;
    logic i_rst;

    logic [9:0] in_mem_addr;
    logic in_mem_re_web;
    logic [31:0] in_mem_write_data;
    logic [3:0] in_mem_byte_en;
    logic [31:0] out_mem_data;

    mem uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .in_mem_addr(in_mem_addr),
        .in_mem_re_web(in_mem_re_web),
        .in_mem_write_data(in_mem_write_data),
        .in_mem_byte_en(in_mem_byte_en),
        .out_mem_data(out_mem_data)
    );

    always #5 i_clk = ~i_clk;

    task write_mem;
        input [9:0] addr;
        input [31:0] data;
        input [3:0] byte_en;
        input string test_name;

        begin
            in_mem_addr = addr;
            in_mem_write_data = data;
            in_mem_byte_en = byte_en;
            in_mem_re_web = 1'b0;   // write mode

            @(posedge i_clk);
            #1;

            $display("WRITE: %s", test_name);
        end
    endtask

    task read_check;
        input [9:0] addr;
        input [31:0] expected_data;
        input string test_name;

        begin
            in_mem_addr = addr;
            in_mem_re_web = 1'b1;   // read mode
            in_mem_byte_en = 4'b0000;
            in_mem_write_data = 32'd0;

            @(posedge i_clk);
            #1;

            if (out_mem_data === expected_data) begin
                $display("PASS: %s | data = %h", test_name, out_mem_data);
            end
            else begin
                $display("FAIL: %s | expected = %h got = %h",
                         test_name, expected_data, out_mem_data);
            end
        end
    endtask

    initial begin
        $dumpfile("mem_tb.vcd");
        $dumpvars(0, mem_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        in_mem_addr = 10'd0;
        in_mem_re_web = 1'b1;
        in_mem_write_data = 32'd0;
        in_mem_byte_en = 4'b0000;

        // Reset active low
        #10;
        i_rst = 1'b1;
        #10;

        $display("Starting Memory Testbench");

        // After reset, memory should read 0
        read_check(10'd5, 32'h00000000, "Read after reset");

        // Full word write
        write_mem(10'd5, 32'hAABBCCDD, 4'b1111, "Full word write");
        read_check(10'd5, 32'hAABBCCDD, "Full word read");

        // Byte 0 write: update [7:0]
        write_mem(10'd5, 32'h000000EE, 4'b0001, "Byte 0 write");
        read_check(10'd5, 32'hAABBCCEE, "Byte 0 read check");

        // Byte 1 write: update [15:8]
        write_mem(10'd5, 32'h0000FF00, 4'b0010, "Byte 1 write");
        read_check(10'd5, 32'hAABBFFEE, "Byte 1 read check");

        // Byte 2 write: update [23:16]
        write_mem(10'd5, 32'h00110000, 4'b0100, "Byte 2 write");
        read_check(10'd5, 32'hAA11FFEE, "Byte 2 read check");

        // Byte 3 write: update [31:24]
        write_mem(10'd5, 32'h22000000, 4'b1000, "Byte 3 write");
        read_check(10'd5, 32'h2211FFEE, "Byte 3 read check");

        // Different address should still be 0
        read_check(10'd6, 32'h00000000, "Different address unchanged");

        // Half word lower bytes using byte_en 0011
        write_mem(10'd10, 32'h00001234, 4'b0011, "Lower halfword write");
        read_check(10'd10, 32'h00001234, "Lower halfword read check");

        // Half word upper bytes using byte_en 1100
        write_mem(10'd10, 32'hABCD0000, 4'b1100, "Upper halfword write");
        read_check(10'd10, 32'hABCD1234, "Upper halfword read check");

        $display("Memory Testbench Completed");
        $finish;
    end

endmodule