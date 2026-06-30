`timescale 1ns/1ps

module processor_tb;

    logic i_clk;
    logic i_rst;

    processor uut (
        .i_clk(i_clk),
        .i_rst(i_rst)
    );

    always #5 i_clk = ~i_clk;

    task check_reg;
        input [4:0] reg_num;
        input [31:0] expected;
        input string test_name;
        begin
            if (uut.inst_ieu.inst_regfile.regs[reg_num] === expected) begin
                $display("PASS: %s | x%0d = %0d", test_name, reg_num, expected);
            end
            else begin
                $display("FAIL: %s | x%0d expected=%0d got=%0d",
                         test_name,
                         reg_num,
                         expected,
                         uut.inst_ieu.inst_regfile.regs[reg_num]);
            end
        end
    endtask

    task check_mem;
        input [9:0] mem_index;
        input [31:0] expected;
        input string test_name;
        begin
            if (uut.inst_mem.memory_reg[mem_index] === expected) begin
                $display("PASS: %s | mem[%0d] = %h", test_name, mem_index, expected);
            end
            else begin
                $display("FAIL: %s | mem[%0d] expected=%h got=%h",
                         test_name,
                         mem_index,
                         expected,
                         uut.inst_mem.memory_reg[mem_index]);
            end
        end
    endtask

    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);

        i_clk = 1'b0;
        i_rst = 1'b0;

        // Keep reset active for some clock cycles
        repeat(2) @(posedge i_clk);

        // Release reset
        i_rst = 1'b1;
        #1;

        /*
            Program loaded into instruction memory:

            x1 = 5
            x2 = 7
            x3 = x1 + x2 = 12
            mem[128] = x3
            x4 = mem[128] = 12
            x5 = x4 + x1 = 17

            Data address used = byte address 512
            Since memory is word addressed internally:
            512 >> 2 = 128
        */

        uut.inst_mem.memory_reg[0]  = 32'h00500093; // addi x1, x0, 5
        uut.inst_mem.memory_reg[1]  = 32'h00000013; // nop
        uut.inst_mem.memory_reg[2]  = 32'h00000013; // nop

        uut.inst_mem.memory_reg[3]  = 32'h00700113; // addi x2, x0, 7
        uut.inst_mem.memory_reg[4]  = 32'h00000013; // nop
        uut.inst_mem.memory_reg[5]  = 32'h00000013; // nop

        uut.inst_mem.memory_reg[6]  = 32'h002081B3; // add x3, x1, x2
        uut.inst_mem.memory_reg[7]  = 32'h00000013; // nop
        uut.inst_mem.memory_reg[8]  = 32'h00000013; // nop

        uut.inst_mem.memory_reg[9]  = 32'h20302023; // sw x3, 512(x0)
        uut.inst_mem.memory_reg[10] = 32'h00000013; // nop
        uut.inst_mem.memory_reg[11] = 32'h00000013; // nop

        uut.inst_mem.memory_reg[12] = 32'h20002203; // lw x4, 512(x0)
        uut.inst_mem.memory_reg[13] = 32'h00000013; // nop
        uut.inst_mem.memory_reg[14] = 32'h00000013; // nop

        uut.inst_mem.memory_reg[15] = 32'h001202B3; // add x5, x4, x1
        uut.inst_mem.memory_reg[16] = 32'h00000013; // nop
        uut.inst_mem.memory_reg[17] = 32'h00000013; // nop

        uut.inst_mem.memory_reg[18] = 32'h0000006F; // jal x0, 0 infinite loop

        $display("Starting Processor Testbench");

        // Run enough cycles for all instructions
        repeat(80) @(posedge i_clk);
        #2;

        check_reg(5'd1, 32'd5,  "ADDI x1");
        check_reg(5'd2, 32'd7,  "ADDI x2");
        check_reg(5'd3, 32'd12, "ADD x3");
        check_mem(10'd128, 32'd12, "SW to memory");
        check_reg(5'd4, 32'd12, "LW x4");
        check_reg(5'd5, 32'd17, "ADD x5");

        $display("Processor Testbench Completed");
        $finish;
    end

endmodule