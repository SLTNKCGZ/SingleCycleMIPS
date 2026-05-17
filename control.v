module control(in, funct, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, lwslt, beqm, swand, swinc, swv);

    input [5:0] in;      // Opcode (instruc[31:26])
    input [5:0] funct;   // Function code (instruc[5:0])

    output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, lwslt, beqm, swand, swinc, swv;

    wire rformat, lw, sw, beq, is_swinc, is_swv;

    // Opcode descriptions
    assign rformat  = ~|in; // in == 000000
    assign lw       =  in[5] & ~in[4] & ~in[3] & ~in[2] &  in[1] &  in[0]; // 100011
    assign sw       =  in[5] & ~in[4] &  in[3] & ~in[2] &  in[1] &  in[0]; // 101011
    assign beq      = ~in[5] & ~in[4] & ~in[3] &  in[2] & ~in[1] & ~in[0]; // 000100
    assign is_swinc =  in[5] & ~in[4] &  in[3] &  in[2] & ~in[1] & ~in[0]; 
    assign swinc    = is_swinc;
    assign is_swv   =  in[5] & ~in[4] & ~in[3] &  in[2] &  in[1] &  in[0]; 
    assign swv      = is_swv;

    // --- R-Type Signals ---
    assign lwslt = rformat & (funct == 6'b010100);
    assign beqm  = rformat & (funct == 6'b011000);
    assign swand = rformat & (funct == 6'b101101);

    assign regdest  = rformat;         
    assign alusrc   = lw | sw | swinc;
    assign memtoreg = lw;              
    
    assign regwrite = (rformat & ~beqm & ~swand) | lw; 
    
    assign memread  = lw | lwslt | beqm;      
    
    assign memwrite = sw | swand | swinc; 
    assign branch   = beq;
    assign aluop1   = rformat;         
    assign aluop0   = beq;

endmodule