`timescale 1ns/1ps

`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module store_tb;

    logic i_clk;
    logic i_rst;

    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [31:0] imm;
    logic [2:0] store_control;

    logic stall_pc;
    logic ignore_curr_inst;
    logic mem_rw_mode;
    logic [31:0] mem_addr;
    logic [31:0] mem_write_data;
    logic [3:0] mem_byte_en;

    store uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .rs1_val(rs1_val),
        .rs2_val(rs2_val),
        .imm(imm),
        .store_control(store_control),
        .stall_pc(stall_pc),
        .ignore_curr_inst(ignore_curr_inst),
        .mem_rw_mode(mem_rw_mode),
        .mem_addr(mem_addr),
        .mem_write_data(mem_write_data),
        .mem_byte_en(mem_byte_en)
    );

    always #5 i_clk = ~i_clk;

    task check_store;
        input [2:0] ctrl;
        input [31:0] base;
        input [31:0] offset;
        input [31:0] data;
        input [31:0] expected_addr;
        input [31:0] expected_data;
        input [3:0] expected_byte_en;
        input string test_name;

        begin
            rs1_val = base;
            imm = offset;
            rs2_val = data;
            store_control = ctrl;

            #1;

            if (stall_pc === 1'b1 &&
                mem_rw_mode === 1'b0 &&
                mem_addr === expected_addr &&
                mem_write_data === expected_data &&
                mem_byte_en === expected_byte_en) begin

                $display("PASS: %s combinational outputs", test_name);

            end
            else begin
                $display("FAIL: %s combinational outputs", test_name);
                $display("  stall_pc expected=1 got=%b", stall_pc);
                $display("  mem_rw_mode expected=0 got=%b", mem_rw_mode);
                $display("  mem_addr expected=%h got=%h", expected_addr, mem_addr);
                $display("  mem_write_data expected=%h got=%h", expected_data, mem_write_data);
                $display("  mem_byte_en expected=%b got=%b", expected_byte_en, mem_byte_en);
            end

            @(posedge i_clk);
            #1;

            if (ignore_curr_inst === 1'b1) begin
                $display("PASS: %s ignore_curr_inst", test_name);
            end
            else begin
                $display("FAIL: %s ignore_curr_inst expected=1 got=%b",
                         test_name, ignore_curr_inst);
            end
        end
    endtask

    initial begin
        $dumpfile("store_tb.vcd");
        $dumpvars(0, store_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        rs1_val = 32'd0;
        rs2_val = 32'd0;
        imm = 32'd0;
        store_control = 3'b000;

        // Reset active low
        #10;
        i_rst = 1'b1;
        #10;

        $display("Starting Store Testbench");

        // No store
        store_control = 3'b000;
        rs1_val = 32'd100;
        imm = 32'd4;
        rs2_val = 32'hAABBCCDD;

        #1;

        if (stall_pc === 1'b0 &&
            mem_rw_mode === 1'b1 &&
            mem_addr === 32'd0 &&
            mem_write_data === 32'd0 &&
            mem_byte_en === 4'b0000) begin

            $display("PASS: No store");

        end
        else begin
            $display("FAIL: No store");
            $display("  stall_pc=%b mem_rw_mode=%b mem_addr=%h mem_write_data=%h mem_byte_en=%b",
                     stall_pc, mem_rw_mode, mem_addr, mem_write_data, mem_byte_en);
        end

        @(posedge i_clk);
        #1;

        if (ignore_curr_inst === 1'b0)
            $display("PASS: No store ignore_curr_inst");
        else
            $display("FAIL: No store ignore_curr_inst expected=0 got=%b", ignore_curr_inst);

        // store_control encoding in your RTL:
        // 001 = SB
        // 010 = SH
        // 011 = SW

        // SB, address[1:0] = 00
        check_store(
            3'b001,
            32'd100,
            32'd0,
            32'hAABBCCDD,
            32'd100,
            32'h000000DD,
            4'b0001,
            "SB addr[1:0]=00"
        );

        // SB, address[1:0] = 01
        check_store(
            3'b001,
            32'd100,
            32'd1,
            32'hAABBCCDD,
            32'd101,
            32'h0000DD00,
            4'b0010,
            "SB addr[1:0]=01"
        );

        // SB, address[1:0] = 10
        check_store(
            3'b001,
            32'd100,
            32'd2,
            32'hAABBCCDD,
            32'd102,
            32'h00DD0000,
            4'b0100,
            "SB addr[1:0]=10"
        );

        // SB, address[1:0] = 11
        check_store(
            3'b001,
            32'd100,
            32'd3,
            32'hAABBCCDD,
            32'd103,
            32'hDD000000,
            4'b1000,
            "SB addr[1:0]=11"
        );

        // SH, address[1] = 0
        check_store(
            3'b010,
            32'd200,
            32'd0,
            32'hAABBCCDD,
            32'd200,
            32'h0000CCDD,
            4'b0011,
            "SH addr[1]=0"
        );

        // SH, address[1] = 1
        check_store(
            3'b010,
            32'd200,
            32'd2,
            32'hAABBCCDD,
            32'd202,
            32'hCCDD0000,
            4'b1100,
            "SH addr[1]=1"
        );

        // SW
        check_store(
            3'b011,
            32'd300,
            32'd4,
            32'hAABBCCDD,
            32'd304,
            32'hAABBCCDD,
            4'b1111,
            "SW"
        );

        $display("Store Testbench Completed");
        $finish;
    end

endmodule