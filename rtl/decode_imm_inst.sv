
`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module decode_imm_inst(
    input logic [31:7] instruction_code,
    output logic [4:0] rs1,
    output logic [4:0] rd,
    output logic [11:0] imm,
    output logic [4:0] alu_control
);

// Edit the code here begin ---------------------------------------------------

    

    always@(*) begin
        rs1=instruction_code[19:15];
        imm=instruction_code[31:20];
        rd=instruction_code[11:7];
        case(instruction_code[14:12]) 
            3'd0: alu_control=5'd16;
            3'd4: alu_control=5'd17;
            3'd6: alu_control=5'd18;
            3'd7: alu_control=5'd19;
            3'd1: begin
                if(instruction_code[31:25]==7'd0) begin
                    alu_control=5'd20;    
                end
                else begin
                    alu_control=5'd0;
                end
            end

            
            3'd5: begin
                if(instruction_code[31:25]==7'b0000000) begin
                    alu_control=5'd21;
                end
                else if(instruction_code[31:25]==7'b0100000) begin
                    alu_control=5'd22;
                end
                else begin
                    alu_control=5'd0;
                end
            end
            
            
            3'd2: alu_control=5'd23;
            3'd3: alu_control=5'd24;
            default: alu_control=5'd0;
        endcase
    end


    
// Edit the code here end -----------------------------------------------------

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/decode_imm_inst.vcd");
        $dumpvars(0, decode_imm_inst);
    end
`endif

endmodule
