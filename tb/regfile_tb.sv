`timescale 1ns / 1ps

module regfile_tb;

    logic        i_clk;
    logic        i_rst;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic        rd_write_control;
    logic [31:0] rd_write_val;
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;

    regfile dut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_write_control(rd_write_control),
        .rd_write_val(rd_write_val),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val)
    );

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);

        i_rst = 1;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0;
        rd_write_control = 1'b0;
        rd_write_val = 32'd0;

        // Reset is active low
        #5;
        i_rst = 0;
        #10;
        i_rst = 1;
        #10;

        // Check reset
        rs1 = 5'd1;
        rs2 = 5'd2;
        #5;

        if (rs1_val == 32'd0 && rs2_val == 32'd0)
            $display("RESET passed");
        else
            $display("RESET failed: rs1_val=%0d rs2_val=%0d", rs1_val, rs2_val);

        // Write 25 to x1
        rd = 5'd1;
        rd_write_val = 32'd25;
        rd_write_control = 1'b1;
        #10;

        rd_write_control = 1'b0;
        rs1 = 5'd1;
        #5;

        if (rs1_val == 32'd25)
            $display("WRITE/READ x1 passed");
        else
            $display("WRITE/READ x1 failed: got %0d", rs1_val);

        // Write 100 to x2
        rd = 5'd2;
        rd_write_val = 32'd100;
        rd_write_control = 1'b1;
        #10;

        rd_write_control = 1'b0;
        rs2 = 5'd2;
        #5;

        if (rs2_val == 32'd100)
            $display("WRITE/READ x2 passed");
        else
            $display("WRITE/READ x2 failed: got %0d", rs2_val);

        // Dual read
        rs1 = 5'd1;
        rs2 = 5'd2;
        #5;

        if (rs1_val == 32'd25 && rs2_val == 32'd100)
            $display("DUAL READ passed");
        else
            $display("DUAL READ failed: rs1_val=%0d rs2_val=%0d", rs1_val, rs2_val);

        // Write disable check
        rd = 5'd1;
        rd_write_val = 32'd999;
        rd_write_control = 1'b0;
        #10;

        rs1 = 5'd1;
        #5;

        if (rs1_val == 32'd25)
            $display("WRITE DISABLE passed");
        else
            $display("WRITE DISABLE failed: got %0d", rs1_val);

        $display("Register File Testbench Completed");
        $finish;
    end

endmodule