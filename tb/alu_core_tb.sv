`timescale 1ns / 1ps

module alu_core_tb;

    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [4:0]  alu_control;
    logic [31:0] rd_write_val;

    alu_core dut (
        .rs1_val(rs1_val),
        .rs2_val(rs2_val),
        .alu_control(alu_control),
        .rd_write_val(rd_write_val)
    );

    initial begin
        $dumpfile("alu_core_tb.vcd");
        $dumpvars(0, alu_core_tb);

        // DEFAULT / NO OPERATION
        rs1_val = 32'd10;
        rs2_val = 32'd5;
        alu_control = 5'd0;
        #10;
        if (rd_write_val == 32'd0)
            $display("DEFAULT passed");
        else
            $display("DEFAULT failed: got %0d", rd_write_val);

        // ADD: 10 + 5 = 15
        rs1_val = 32'd10;
        rs2_val = 32'd5;
        alu_control = 5'd1;
        #10;
        if (rd_write_val == 32'd15)
            $display("ADD passed");
        else
            $display("ADD failed: got %0d", rd_write_val);

        // SUB: 10 - 5 = 5
        rs1_val = 32'd10;
        rs2_val = 32'd5;
        alu_control = 5'd2;
        #10;
        if (rd_write_val == 32'd5)
            $display("SUB passed");
        else
            $display("SUB failed: got %0d", rd_write_val);

        // XOR
        rs1_val = 32'h0000_00FF;
        rs2_val = 32'h0000_0F0F;
        alu_control = 5'd3;
        #10;
        if (rd_write_val == 32'h0000_0FF0)
            $display("XOR passed");
        else
            $display("XOR failed: got %h", rd_write_val);

        // OR
        rs1_val = 32'h0000_00F0;
        rs2_val = 32'h0000_0F0F;
        alu_control = 5'd4;
        #10;
        if (rd_write_val == 32'h0000_0FFF)
            $display("OR passed");
        else
            $display("OR failed: got %h", rd_write_val);

        // AND
        rs1_val = 32'h0000_00FF;
        rs2_val = 32'h0000_0F0F;
        alu_control = 5'd5;
        #10;
        if (rd_write_val == 32'h0000_000F)
            $display("AND passed");
        else
            $display("AND failed: got %h", rd_write_val);

        // SLL: 1 << 3 = 8
        rs1_val = 32'd1;
        rs2_val = 32'd3;
        alu_control = 5'd6;
        #10;
        if (rd_write_val == 32'd8)
            $display("SLL passed");
        else
            $display("SLL failed: got %0d", rd_write_val);

        // SRL: 64 >> 2 = 16
        rs1_val = 32'd64;
        rs2_val = 32'd2;
        alu_control = 5'd7;
        #10;
        if (rd_write_val == 32'd16)
            $display("SRL passed");
        else
            $display("SRL failed: got %0d", rd_write_val);

        $display("ALU Core Testbench Completed");
        $finish;
    end

endmodule