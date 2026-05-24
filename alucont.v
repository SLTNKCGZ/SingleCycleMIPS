module alucont(aluop1, aluop0, f5, f4, f3, f2, f1, f0, gout);
    input aluop1, aluop0, f5, f4, f3, f2, f1, f0;
    output reg [2:0] gout;

    always @(*) begin
        
        if (~(aluop1 | aluop0)) gout = 3'b010; // Load/Store 
        else if (aluop0)        gout = 3'b110; // Normal Branch
        else if (aluop1) begin // R-type
            
            // --- LWSLT (Funct 20: 010100 -> f4=1, f2=1) ---
            if (~f5 & f4 & ~f3 & f2 & ~f1 & ~f0) 
                gout = 3'b010; 
            
            // --- BEQM (Funct 24: 011000 -> f4=1, f3=1) ---
            else if (~f5 & f4 & f3 & ~f2 & ~f1 & ~f0) 
                gout = 3'b010; 

            else if (f5 & ~f4 & f3 & f2 & ~f1 & f0)
                gout = 3'b000;

            // ---R-type instructions ---
            else if (~(f4|f3|f2|f1|f0)) gout = 3'b010; // add (funct 0)
            else if (f1 & f3)           gout = 3'b111; // slt
            else if (f1 & ~f3)          gout = 3'b110; // sub
            else if (f2 & f0)           gout = 3'b001; // or
            else if (f2 & ~f0)          gout = 3'b000; // and
            else                        gout = 3'b010; // add
        end
    end
endmodule
