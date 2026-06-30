
`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module decode_jump_inst(
    input logic [31:0] instruction_code,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [31:0] imm,
    output logic [1:0] jump_control
);

// Edit the code here begin ---------------------------------------------------
    
    always@(*) begin
        jump_control=2'd0;
        rd=instruction_code[11:7];
        rs1=5'b0;
        imm=32'b0;
        case(instruction_code[6:0])
            7'b1101111 : begin
                rd=instruction_code[11:7];
                imm[31:21]={11{instruction_code[31]}};
                imm[20]=instruction_code[31];
                imm[10:1]=instruction_code[30:21];
                imm[11]=instruction_code[20];
                imm[19:12]=instruction_code[19:12];
                imm[0]=1'b0;
                jump_control=2'd1;
            end
            7'b1100111 : begin    
                if(instruction_code[14:12]==3'd0) begin
                    imm={{20{instruction_code[31]}},instruction_code[31:20]};
                    rs1=instruction_code[19:15];
                    rd=instruction_code[11:7];
                    jump_control=2'd2;
                end

                else
                jump_control=2'd0;
            end
            default:begin 
                jump_control=2'd0;
                rd=instruction_code[11:7];
                rs1=5'b0;
                imm=32'b0;
            end
        endcase
    end

// Edit the code here end -----------------------------------------------------

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/decode_jump_inst.vcd");
        $dumpvars(0, decode_jump_inst);
    end
`endif

endmodule
