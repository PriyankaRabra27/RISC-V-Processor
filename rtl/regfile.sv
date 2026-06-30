
module regfile(
    input logic i_clk,
    input logic i_rst,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic rd_write_control,
    input logic [31:0] rd_write_val,
    output logic [31:0] rs1_val,
    output logic [31:0] rs2_val
);

logic [31:0] regs [0:31];

// Edit the code here begin ---------------------------------------------------

//    assign rs1_val=regs[rs1];
//    assign rs2_val=regs[rs2];

    always_comb begin
        rs1_val=regs[rs1];
        rs2_val=regs[rs2];
        
    end

   always@(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
        for(int i=0;i<32;i++) begin
            for(int j=0;j<32;j++)
            regs[j][i]<=0;
        end
    end
    else begin
        if(rd_write_control) begin
            if(rd!=0)
            regs[rd]<=rd_write_val;
        end
    end
   end


    
// Edit the code here end -----------------------------------------------------
    
    generate
        
        for(genvar ii=0;ii<32;ii+=1) begin : gen_reg_temp
            wire [31:0] reg_dump;
            assign reg_dump=regs[ii];
        end

    endgenerate
/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/regfile.vcd");
        $dumpvars(0, regfile);
    end
`endif

endmodule
