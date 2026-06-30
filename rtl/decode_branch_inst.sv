
`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module decode_branch_inst(
    input logic [31:7] instruction_code,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [12:0] imm,
    output logic [2:0] branch_control
);

// Edit the code here begin ---------------------------------------------------

    always@(*) begin
        rs1=instruction_code[19:15];
        rs2=instruction_code[24:20];
        imm={instruction_code[31],instruction_code[7],instruction_code[30:25],instruction_code[11:8],1'b0};
        branch_control=3'd0;
        case(instruction_code[14:12])
            3'd0:branch_control=3'd1;
            3'd1:branch_control=3'd2;
            3'd4:branch_control=3'd3;
            3'd5:branch_control=3'd4;
            3'd6:branch_control=3'd5;
            3'd7:branch_control=3'd6;
            default:branch_control=3'd0;
        endcase

    end
    
// Edit the code here end -----------------------------------------------------

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/decode_branch_inst.vcd");
        $dumpvars(0, decode_branch_inst);
    end
`endif

endmodule
