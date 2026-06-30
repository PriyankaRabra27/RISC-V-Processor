`timescale 1ns/1ps

`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module jump_tb;

    logic i_clk;
    logic i_rst;

    logic [31:0] pc_prev;
    logic [31:0] imm;
    logic [31:0] rs1_val;
    logic [1:0] jump_control;

    logic rd_write_control;
    logic [31:0] rd_write_val;
    logic pc_update_control;
    logic [31:0] pc_update_val;
    logic ignore_curr_inst;

    jump uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .pc_prev(pc_prev),
        .imm(imm),
        .rs1_val(rs1_val),
        .jump_control(jump_control),
        .rd_write_control(rd_write_control),
        .rd_write_val(rd_write_val),
        .pc_update_control(pc_update_control),
        .pc_update_val(pc_update_val),
        .ignore_curr_inst(ignore_curr_inst)
    );

    always #5 i_clk = ~i_clk;

    task check_jump;
        input [1:0] ctrl;
        input [31:0] pc;
        input [31:0] immediate;
        input [31:0] rs1;
        input expected_pc_update_control;
        input [31:0] expected_pc_update_val;
        input expected_rd_write_control;
        input [31:0] expected_rd_write_val;
        input expected_ignore;
        input string test_name;

        begin
            pc_prev = pc;
            imm = immediate;
            rs1_val = rs1;
            jump_control = ctrl;

            #10;

            if (pc_update_control === expected_pc_update_control &&
                pc_update_val === expected_pc_update_val &&
                rd_write_control === expected_rd_write_control &&
                rd_write_val === expected_rd_write_val &&
                ignore_curr_inst === expected_ignore) begin

                $display("PASS: %s", test_name);

            end
            else begin
                $display("FAIL: %s", test_name);
                $display("  pc_update_control: expected=%b got=%b",
                         expected_pc_update_control, pc_update_control);
                $display("  pc_update_val: expected=%0d got=%0d",
                         expected_pc_update_val, pc_update_val);
                $display("  rd_write_control: expected=%b got=%b",
                         expected_rd_write_control, rd_write_control);
                $display("  rd_write_val: expected=%0d got=%0d",
                         expected_rd_write_val, rd_write_val);
                $display("  ignore_curr_inst: expected=%b got=%b",
                         expected_ignore, ignore_curr_inst);
            end
        end
    endtask

    initial begin
        $dumpfile("jump_tb.vcd");
        $dumpvars(0, jump_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        pc_prev = 32'd0;
        imm = 32'd0;
        rs1_val = 32'd0;
        jump_control = 2'b00;

        // Reset active low
        #10;
        i_rst = 1'b1;
        #10;

        $display("Starting Jump Testbench");

        // Assumed jump_control encoding:
        // 00 = no jump
        // 01 = JAL
        // 10 = JALR

        // No jump
        check_jump(
            2'b00,
            32'd100,
            32'd16,
            32'd200,
            1'b0,
            32'd0,
            1'b0,
            32'd0,
            1'b0,
            "No jump"
        );

        // JAL: pc_update_val = pc_prev + imm
        // rd_write_val = pc_prev + 4
        check_jump(
            2'b01,
            32'd100,
            32'd16,
            32'd200,
            1'b1,
            32'd116,
            1'b1,
            32'd104,
            1'b1,
            "JAL"
        );

        // JALR: pc_update_val = rs1_val + imm
        // rd_write_val = pc_prev + 4
        check_jump(
            2'b10,
            32'd100,
            32'd16,
            32'd200,
            1'b1,
            32'd216,
            1'b1,
            32'd104,
            1'b1,
            "JALR"
        );

        $display("Jump Testbench Completed");
        $finish;
    end

endmodule