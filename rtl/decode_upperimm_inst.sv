
`ifndef FILE_INCL
    `include "processor_defines.sv"
`endif

module decode_upperimm_inst(
    input logic [31:0] instruction_code,
    output logic [4:0] rd,
    output logic [31:0] imm,
    output logic [4:0] alu_control
);

// Edit the code here begin ---------------------------------------------------
  
    always@(*) begin
        rd=instruction_code[11:7];
        imm[31:12]=instruction_code[31:12];
        imm[11:0]=12'b0;
        case(instruction_code[6:0]) 
            7'd55 : alu_control=5'd28;
            7'd23 : alu_control=5'd29;
            default: alu_control=5'd0;
        endcase
    end

    
// Edit the code here end -----------------------------------------------------

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/decode_upperimm_inst.vcd");
        $dumpvars(0, decode_upperimm_inst);
    end
`endif

endmodule
