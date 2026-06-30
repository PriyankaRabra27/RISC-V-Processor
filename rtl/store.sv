
`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module store(
    input logic i_clk,
    input logic i_rst,
    input logic [31:0] rs1_val,
    input logic [31:0] rs2_val,
    input logic [31:0] imm,
    input logic [2:0] store_control,
    output logic stall_pc,
    output logic ignore_curr_inst,
    output logic mem_rw_mode,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_write_data,
    output logic [3:0] mem_byte_en
);

// Edit the code here begin ---------------------------------------------------   
    always@(posedge i_clk or negedge i_rst) begin
        if(!i_rst) begin
            
            ignore_curr_inst <= 'b0;
        end
        else if(store_control==3'd1) begin
         
            ignore_curr_inst<=1'b1;

        end

        else if(store_control==3'd2) begin
            
            ignore_curr_inst<=1'b1;

        end

        else if(store_control==3'd3) begin
           
            ignore_curr_inst<='b1;
        end
        else begin
            
            ignore_curr_inst <= 'b0;
        end
    end

    always@(*) begin
        mem_rw_mode = 1'b1;
        mem_addr = 32'b0;
        mem_write_data = 32'b0;
        mem_byte_en = 1'b0;
        stall_pc <= 'b0;
        if(store_control==3'd1) begin
            mem_rw_mode=1'b0;
            mem_addr=rs1_val+imm;
            stall_pc <= 'b1;
            if(mem_addr[1:0]==2'b00) begin
                mem_byte_en=4'b0001;
                mem_write_data={24'b0,rs2_val[7:0]};
            end
            else if(mem_addr[1:0]==2'b01) begin
                mem_byte_en=4'b0010;
                mem_write_data={16'b0,rs2_val[7:0],8'b0};
            end
            else if(mem_addr[1:0]==2'b10) begin
                mem_byte_en=4'b0100;
                mem_write_data={8'b0,rs2_val[7:0],16'b0};
            end
            else if(mem_addr[1:0]==2'b11) begin
                mem_byte_en=4'b1000;
                mem_write_data={rs2_val[7:0],24'b0};
            end

        end

        else if(store_control==3'd2) begin
            mem_rw_mode=1'b0;
            mem_addr=rs1_val+imm;
            stall_pc <= 'b1;
            if(mem_addr[1]==1'b0) begin
                mem_byte_en=4'b0011;
                mem_write_data={16'b0,rs2_val[15:0]};
            end
            else begin
                mem_byte_en=4'b1100;
                mem_write_data={rs2_val[15:0],16'b0};
            end
        end

        else if(store_control==3'd3) begin
            mem_rw_mode = 1'b0;
            mem_addr = rs1_val + imm;
            mem_write_data = rs2_val;
            mem_byte_en = 4'b1111;
            stall_pc <= 'b1;
        end
        else begin
            mem_rw_mode = 1'b1;
            mem_addr = 32'b0;
            mem_write_data = 32'b0;
            mem_byte_en = 4'b0;
            stall_pc <= 'b0;
        end
    end





            
// Edit the code here end -----------------------------------------------------

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/store.vcd");
        $dumpvars(0, store);
    end
`endif

endmodule
