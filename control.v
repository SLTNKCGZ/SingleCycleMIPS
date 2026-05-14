module control(in, funct, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, lwslt, beqm, swand);

    

    input [5:0] in;     // Opcode (instruc[31:26])

    input [5:0] funct;  // Function code (instruc[5:0])

    

    // Ç?k??lar (aluop2 yerine genel standart olan aluop0 ismini kulland?m)

    output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, lwslt, beqm, swand;

    

    wire rformat, lw, sw, beq;



    // Opcode tan?mlamalar?

    assign rformat = ~|in; // in == 000000

    assign lw      =  in[5] & ~in[4] & ~in[3] & ~in[2] &  in[1] &  in[0]; // 100011

    assign sw      =  in[5] & ~in[4] &  in[3] & ~in[2] &  in[1] &  in[0]; // 101011

    assign beq     = ~in[5] & ~in[4] & ~in[3] &  in[2] & ~in[1] & ~in[0]; // 000100



    // --- LWSLT Sinyalinin Üretilmesi ---

    // E?er komut R-format ise VE funct 20 (Binary: 010100) ise lwslt 1 olur.

    assign lwslt = rformat & (funct == 6'b010100);

    assign beqm = rformat & (funct == 6'b011000);

    assign swand = rformat & (funct == 6'b101101);



    // --- Kontrol Sinyali Atamalar? ---

    assign regdest  = rformat;         
    assign alusrc   = lw | sw;         
    assign memtoreg = lw;              
    
    // D?KKAT: beqm bir branch komutudur, Register'a YAZMA YAPMAZ!
    assign regwrite = (rformat & ~beqm & ~swand) | lw; 
    
    // D?KKAT: lwslt ve beqm bellekten veri okumak zorundad?r
    assign memread  = lw | lwslt | beqm;      
    
    assign memwrite = sw | swand;
    assign branch   = beq;
    assign aluop1   = rformat;         
    assign aluop0   = beq;



endmodule
