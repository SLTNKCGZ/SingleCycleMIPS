module alucont(aluop1, aluop0, f5, f4, f3, f2, f1, f0, gout);
    input aluop1, aluop0, f5, f4, f3, f2, f1, f0;
    output reg [2:0] gout;

    always @(*) begin
        // Varsay?lan durumlar
        if (~(aluop1 | aluop0)) gout = 3'b010; // Load/Store için toplama (Add)
        else if (aluop0)        gout = 3'b110; // Normal Branch için ç?karma (Sub)
        else if (aluop1) begin // R-type
            
            // --- LWSLT ?Ç? (Funct 20: 010100 -> f4=1, f2=1) ---
            if (~f5 & f4 & ~f3 & f2 & ~f1 & ~f0) 
                gout = 3'b010; // Adres hesab? için toplama
            
            // --- BEQM ?Ç?N EKLENEN SATIR (Funct 24: 011000 -> f4=1, f3=1) ---
            else if (~f5 & f4 & f3 & ~f2 & ~f1 & ~f0) 
                gout = 3'b010; // Adres hesab? için toplama

            else if (f5 & ~f4 & f3 & f2 & ~f1 & f0)
                gout = 3'b000;

            // --- Di?er standart R-tipi komutlar ---
            else if (~(f4|f3|f2|f1|f0)) gout = 3'b010; // add (funct 0)
            else if (f1 & f3)           gout = 3'b111; // slt
            else if (f1 & ~f3)          gout = 3'b110; // sub
            else if (f2 & f0)           gout = 3'b001; // or
            else if (f2 & ~f0)          gout = 3'b000; // and
            else                        gout = 3'b010; // Varsay?lan Add
        end
    end
endmodule
