`timescale 1ns/1ps

`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module load_tb;

    logic i_clk;
    logic i_rst;

    logic [31:0] rs1_val;
    logic [31:0] imm;
    logic [31:0] mem_data;
    logic [4:0] rd_in;
    logic [2:0] load_control;

    logic stall_pc;
    logic [31:0] mem_addr;
    logic ignore_curr_inst;
    logic rd_write_control;
    logic [4:0] rd_out;
    logic [31:0] rd_write_val;
    logic mem_rw_mode;

    load uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .rs1_val(rs1_val),
        .imm(imm),
        .mem_data(mem_data),
        .rd_in(rd_in),
        .load_control(load_control),
        .stall_pc(stall_pc),
        .mem_addr(mem_addr),
        .ignore_curr_inst(ignore_curr_inst),
        .rd_write_control(rd_write_control),
        .rd_out(rd_out),
        .rd_write_val(rd_write_val),
        .mem_rw_mode(mem_rw_mode)
    );

    always #5 i_clk = ~i_clk;

    task check_load;
        input [2:0] ctrl;
        input [31:0] base;
        input [31:0] offset;
        input [31:0] data_from_mem;
        input [4:0] rd;
        input string test_name;

        begin
            rs1_val = base;
            imm = offset;
            mem_data = data_from_mem;
            rd_in = rd;
            load_control = ctrl;

            #1;

            if (stall_pc === 1'b1 &&
                mem_addr === (base + offset) &&
                mem_rw_mode === 1'b1) begin
                $display("PASS: %s address phase", test_name);
            end
            else begin
                $display("FAIL: %s address phase", test_name);
                $display("  stall_pc expected=1 got=%b", stall_pc);
                $display("  mem_addr expected=%0d got=%0d", base + offset, mem_addr);
                $display("  mem_rw_mode expected=1 got=%b", mem_rw_mode);
            end

            @(posedge i_clk);
            #1;

            if (rd_write_control === 1'b1 &&
                rd_out === rd &&
                ignore_curr_inst === 1'b1) begin
                $display("PASS: %s writeback control", test_name);
            end
            else begin
                $display("FAIL: %s writeback control", test_name);
                $display("  rd_write_control expected=1 got=%b", rd_write_control);
                $display("  rd_out expected=%0d got=%0d", rd, rd_out);
                $display("  ignore_curr_inst expected=1 got=%b", ignore_curr_inst);
            end
        end
    endtask

    initial begin
        $dumpfile("load_tb.vcd");
        $dumpvars(0, load_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        rs1_val = 32'd0;
        imm = 32'd0;
        mem_data = 32'd0;
        rd_in = 5'd0;
        load_control = 3'b000;

        // Reset active low
        #10;
        i_rst = 1'b1;
        #10;

        $display("Starting Load Testbench");

        // No load
        load_control = 3'b000;
        rs1_val = 32'd100;
        imm = 32'd4;
        mem_data = 32'h12345678;
        rd_in = 5'd5;

        #10;

                if (stall_pc === 1'b0 &&
            rd_write_control === 1'b0 &&
            ignore_curr_inst === 1'b0)
            $display("PASS: No load");
        else
            $display("FAIL: No load | stall_pc=%b rd_write_control=%b ignore_curr_inst=%b",
                     stall_pc, rd_write_control, ignore_curr_inst);

        // Custom encoding assumption:
        // 001 = load active
        // This checks address phase and writeback control.
        check_load(3'b001, 32'd100, 32'd8, 32'h000000AA, 5'd3, "Load test 1");

        check_load(3'b001, 32'd200, 32'd16, 32'h12345678, 5'd10, "Load test 2");

        $display("Load Testbench Completed");
        $finish;
    end

endmodule