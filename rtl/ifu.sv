module ifu(
    input logic i_clk,
    input logic i_rst,
    input logic stall_pc,
    input logic pc_update_control,
    input logic [31:0] pc_update_val,
    output logic [31:0] pc,
    output logic [31:0] pc_prev
);

// Edit the code here begin ---------------------------------------------------
    always@(posedge i_clk or negedge i_rst) begin
        
        if(!i_rst) begin
            pc<=0;
            pc_prev<=0;
            
        end
        else if(stall_pc) begin
            pc <= pc;
            pc_prev<=pc;
        end
        else if(pc_update_control) begin
            pc <= pc_update_val;  
            pc_prev<=pc; 
        end
        else begin
            pc <= pc + 4;
            pc_prev<=pc;
        end
    end
    
    
    
// Edit the code here end -----------------------------------------------------
    

/*
	Following section is necessary for dumping waveforms. This is needed for debug and simulations
*/

`ifndef SUBMODULE_DISABLE_WAVES
    initial begin
        $dumpfile("./sim_build/ifu.vcd");
        $dumpvars(0, ifu);
    end
`endif

endmodule
