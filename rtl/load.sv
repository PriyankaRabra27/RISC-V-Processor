`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module load(
    input logic i_clk,
    input logic i_rst,
    input logic [31:0] rs1_val,
    input logic [31:0] imm,
    input logic [31:0] mem_data,
    input logic [4:0] rd_in,
    input logic [2:0] load_control,
    output logic stall_pc,
    output logic [31:0] mem_addr,
    output logic ignore_curr_inst, //sequential  
    output logic rd_write_control, //sequential
    output logic [4:0] rd_out, //sequential
    output logic [31:0] rd_write_val, 
    output logic mem_rw_mode

);
reg [2:0] temp;
reg [31:0] temp_addr;
// Edit the code here begin --------------------------------------------------
always @(*) begin 
    if(load_control) begin 
        stall_pc=1'b1;
        mem_addr=rs1_val+imm;
        mem_rw_mode=1'b1;
    end
    else begin 
        stall_pc=1'b0;
        mem_addr=32'd0;
        mem_rw_mode=1'b1;
    end

    case(temp)    
    3'd0: rd_write_val=32'd0;
    3'd1: begin 
        case(temp_addr[1:0])
        2'b00: rd_write_val={{24{mem_data[7]}},mem_data[7:0]};
        2'b01: rd_write_val={{24{mem_data[15]}},mem_data[15:8]};
        2'b10: rd_write_val={{24{mem_data[23]}},mem_data[23:16]};
        2'b11: rd_write_val={{24{mem_data[31]}},mem_data[31:24]};        
        endcase
    end
    3'd2: begin 
        case(temp_addr[1])
        1'b0: rd_write_val={{16{mem_data[15]}},mem_data[15:0]};
        1'b1: rd_write_val={{16{mem_data[31]}},mem_data[31:16]};
        endcase
    end
    3'd3: rd_write_val=mem_data;
    3'd4: begin 
        case(temp_addr[1:0])
        2'b00: rd_write_val={24'd0,mem_data[7:0]};
        2'b01: rd_write_val={24'd0,mem_data[15:8]};
        2'b10: rd_write_val={24'd0,mem_data[23:16]};
        2'b11: rd_write_val={24'd0,mem_data[31:24]};        
        endcase
    end
    3'd5: begin 
        case(temp_addr[1])
        1'b0: rd_write_val={16'd0,mem_data[15:0]};
        1'b1: rd_write_val={16'd0,mem_data[31:16]};  
        endcase
    end
    default: rd_write_val=32'd0;
    endcase
end


always @(posedge i_clk or negedge i_rst) begin 
    if (!i_rst) begin 
        ignore_curr_inst<=1'b0;
        rd_out<=5'd0;
        rd_write_control<=1'b0;
        temp<=3'd0;
    end
    else begin 
        if(load_control) begin 
        ignore_curr_inst<=1'b1;
        rd_out<=rd_in;
        rd_write_control<=1'b1;
        temp<=load_control;
        temp_addr<=mem_addr;
        end
        else begin 
            ignore_curr_inst<=1'b0;
            rd_out<=5'd0;
            rd_write_control<=1'b0;
            temp<=3'd0;
        end
    end    
end


`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/load.vcd");
        $dumpvars(0, load);
    end
`endif

    
endmodule   
    
// Edit the code here end -----------------------------------------------------

/*
    Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/



