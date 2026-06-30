`timescale 1ns/1ps

`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module branch_tb;

    logic i_clk;
    logic i_rst;

    logic [31:0] pc_prev;
    logic [31:0] imm;
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [2:0] branch_control;

    logic pc_update_control;
    logic [31:0] pc_update_val;
    logic ignore_curr_inst;

    branch uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .pc_prev(pc_prev),
        .imm(imm),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val),
        .branch_control(branch_control),
        .pc_update_control(pc_update_control),
        .pc_update_val(pc_update_val),
        .ignore_curr_inst(ignore_curr_inst)
    );

    always #5 i_clk = ~i_clk;

    task check_branch;
        input [2:0] ctrl;
        input [31:0] r1;
        input [31:0] r2;
        input expected_taken;
        input string test_name;

        begin
            pc_prev = 32'd100;
            imm = 32'd16;
            rs1_val = r1;
            rs2_val = r2;
            branch_control = ctrl;

            @(posedge i_clk);
            #1;

            if (pc_update_control === expected_taken) begin
                if (expected_taken == 1'b1) begin
                    if (pc_update_val === (pc_prev + imm) && ignore_curr_inst === 1'b1) begin
                        $display("PASS: %s", test_name);
                    end
                    else begin
                        $display("FAIL: %s | pc_update_val=%0d expected_pc=%0d ignore=%b",
                                 test_name, pc_update_val, pc_prev + imm, ignore_curr_inst);
                    end
                end
                else begin
                    if (ignore_curr_inst === 1'b0) begin
                        $display("PASS: %s", test_name);
                    end
                    else begin
                        $display("FAIL: %s | branch not taken but ignore_curr_inst=%b",
                                 test_name, ignore_curr_inst);
                    end
                end
            end
            else begin
                $display("FAIL: %s | expected_taken=%b got=%b",
                         test_name, expected_taken, pc_update_control);
            end
        end
    endtask

    initial begin
        $dumpfile("branch_tb.vcd");
        $dumpvars(0, branch_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        pc_prev = 32'd0;
        imm = 32'd0;
        rs1_val = 32'd0;
        rs2_val = 32'd0;
        branch_control = 3'b000;

        // Reset active low
        #10;
        i_rst = 1'b1;
        #10;

        $display("Starting Branch Testbench");

        // Custom branch_control encoding used in your RTL
        // 000 = no branch
        // 001 = BEQ
        // 010 = BNE
        // 011 = BLT
        // 100 = BGE
        // 101 = BLTU
        // 110 = BGEU

        check_branch(3'b000, 32'd5, 32'd5, 1'b0, "No branch");

        check_branch(3'b001, 32'd5, 32'd5, 1'b1, "BEQ taken");
        check_branch(3'b001, 32'd5, 32'd7, 1'b0, "BEQ not taken");

        check_branch(3'b010, 32'd5, 32'd7, 1'b1, "BNE taken");
        check_branch(3'b010, 32'd5, 32'd5, 1'b0, "BNE not taken");

        check_branch(3'b011, -32'sd1, 32'd1, 1'b1, "BLT taken signed");
        check_branch(3'b011, 32'd5, 32'd2, 1'b0, "BLT not taken signed");

        check_branch(3'b100, 32'd5, 32'd2, 1'b1, "BGE taken signed");
        check_branch(3'b100, -32'sd1, 32'd1, 1'b0, "BGE not taken signed");

        check_branch(3'b101, 32'd1, 32'd2, 1'b1, "BLTU taken unsigned");
        check_branch(3'b101, 32'd5, 32'd2, 1'b0, "BLTU not taken unsigned");

        check_branch(3'b110, 32'd5, 32'd2, 1'b1, "BGEU taken unsigned");
        check_branch(3'b110, 32'd1, 32'd2, 1'b0, "BGEU not taken unsigned");

        $display("Branch Testbench Completed");
        $finish;
    end

endmodule