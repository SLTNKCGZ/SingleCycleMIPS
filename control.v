module control(in, funct, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, use_shamt, lwslt, beqm, 
swand, swinc, swv, bnpos, balerr);
    input [5:0] in;     
    input [5:0] funct;  
    
    
    output [1:0] memtoreg;
    
    output alusrc, regwrite, regdest, memread, memwrite, branch, aluop1, aluop0, lwslt, beqm, 
    use_shamt, swand, swinc, swv, bnpos, balerr;
    
    wire rformat, lw, sw, beq;

    assign rformat = ~|in; 
    assign lw      =  in[5] & ~in[4] & ~in[3] & ~in[2] &  in[1] &  in[0]; 
    assign sw      =  in[5] & ~in[4] &  in[3] & ~in[2] &  in[1] &  in[0]; 
    assign beq     = ~in[5] & ~in[4] & ~in[3] &  in[2] & ~in[1] & ~in[0]; 

    assign lwslt  = rformat & (funct == 6'b010100); 
    assign beqm   = rformat & (funct == 6'b011000); 
    assign swand  = rformat & (funct == 6'b101101);
    assign swinc  =  in[5] & ~in[4] &  in[3] &  in[2] & ~in[1] & ~in[0];
    assign swv    =  in[5] & ~in[4] & ~in[3] &  in[2] &  in[1] &  in[0];
    assign bnpos  = ~in[5] &  in[4] &  in[3] & ~in[2] & ~in[1] & ~in[0];
    assign balerr =  in[5] & ~in[4] &  in[3] &  in[2] &  in[1] &  in[0];

    assign use_shamt = lwslt | beqm;
   
    // memtoreg[1:0] -> 00: ALU, 01: Memory(lw), 10: lt(lwslt), 11: PC+4(balerr)
    assign memtoreg[1] = lwslt | balerr;
    assign memtoreg[0] = lw | balerr;
    
    // =========================================================
    assign regdest  = rformat; 
    assign alusrc   = lw | sw | swinc;         
    assign regwrite = (rformat & ~beqm & ~swand) | lw | balerr; 
    assign memread  = lw | lwslt | beqm;      
    assign memwrite = sw | swand | swinc | swv;
    assign branch   = beq;
    assign aluop1   = rformat;         
    assign aluop0   = beq;             
endmodule
