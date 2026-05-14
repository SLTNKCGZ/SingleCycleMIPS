module processor;
reg [31:0] pc; //32-bit program counter
reg clk; //clock

// 128 byte data and instruction memory
reg [7:0] datmem[0:127], mem[0:127]; 

wire [31:0] 
dataa,      //Read data 1 output of Register File
datab,      //Read data 2 output of Register File
datac,
out2,       //Output of mux with ALUSrc control-mult2
out3,       //Output of mux with MemToReg control-mult3
out4,       //Output of mux with (Branch&ALUZero) control-mult4
out5,       //Output of swand Data Memory MUX
sum,        //ALU result
extad,      //Output of sign-extend unit
adder1out,  //Output of adder which adds PC and 4-add1
adder2out,  //Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,     //Output of shift left 2 unit
sextshamt;  //Output of sign_extend of shamt

wire [5:0] inst31_26;   //31-26 bits of instruction
wire [5:0] 
inst25_21,  //25-21 bits of instruction
inst20_16,  //20-16 bits of instruction
inst10_6,   //10-6 bits of instruction
inst15_11;  //15-11 bits of instruction

wire [4:0] out1; // Register adresleri 5 bittir

wire [15:0] inst15_0;   //15-0 bits of instruction

wire [31:0] instruc,    //current instruction
dpack;          //Read data output of memory (data read from memory)

wire [2:0] gout;    //Output of ALU control unit

wire zout, gt, lt, eq, pcsrc; // Control flags

//Control signals
wire regdest, alusrc, beqm, lwslt, swand, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0;
wire use_shamt, ifBeqm;

//32-size register file
reg [31:0] registerfile[0:31];
integer i;

// datamemory connections
always @(posedge clk)
if (memwrite)
begin 
    // MUX'tan gelen out5 verisini byte byte bellege yaziyoruz
    datmem[sum[6:0]+3] = out5[7:0];
    datmem[sum[6:0]+2] = out5[15:8];
    datmem[sum[6:0]+1] = out5[23:16];
    datmem[sum[6:0]]   = out5[31:24];
end

//instruction memory
assign instruc = {mem[pc[6:0]], mem[pc[6:0]+1], mem[pc[6:0]+2], mem[pc[6:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst10_6  = instruc[10:6];
assign inst15_0  = instruc[15:0];

// registers
assign dataa = registerfile[inst25_21]; //Read register 1
assign datab = registerfile[inst20_16]; //Read register 2
assign datac = registerfile[inst15_11]; //Read register 3

always @(posedge clk)
 registerfile[out1] = regwrite ? out3 : registerfile[out1]; 

//read data from memory, sum stores address
assign dpack = {datmem[sum[6:0]], datmem[sum[6:0]+1], datmem[sum[6:0]+2], datmem[sum[6:0]+3]};

// Isaret (Signal) Tanimlamalari
assign ifBeqm = beqm && eq; 
assign use_shamt = lwslt | beqm; 

//multiplexers
mult2_to_1_5  mult1(out1, instruc[20:16], instruc[15:11], regdest); 
mult3_to_1_32 mult2(out2, datab, extad, sextshamt, use_shamt, alusrc);
mult3_to_1_32 mult3(out3, sum, dpack, {31'b0, lt}, lwslt, memtoreg);
mult3_to_1_32 mult4(out4, adder1out, adder2out, datac, ifBeqm, pcsrc);

// Data Memory "Write Data" girisini secen 32-bit MUX
mult2_to_1_32 mult5(out5, datab, datac, swand); 

// load pc
always @(negedge clk)
pc = out4;

// comparision
comparator32 comp1(gt, lt, eq, datab, dpack);

//ALU unit
alu32 alu1(sum, dataa, out2, zout, gout);

//adder which adds PC and 4
adder add1(pc, 32'h4, adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out, sextad, adder2out);

// Control unit
control cont(
    instruc[31:26], 
    instruc[5:0], 
    regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch,
    aluop1, aluop0, 
    lwslt,
    beqm,
    swand
);

//Sign extend unit
signext sext(instruc[15:0], extad);

//sign_extend unit of shamt
signExtend5_to_32 sext2(instruc[10:6], sextshamt);

//ALU control unit (Typo duzeltildi: instruc[5])
alucont acont(aluop1, aluop0, instruc[5], instruc[4], instruc[3], instruc[2], instruc[1], instruc[0], gout);

//Shift-left 2 unit
shift shift2(sextad, extad);

//AND gate
assign pcsrc = branch && zout; 

//initialize datamemory,instruction memory and registers
initial
begin
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/singlecycleMIPS/singlecycleMIPS-lite-commented/initDm.dat", datmem); 
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/singlecycleMIPS/singlecycleMIPS-lite-commented/initIM.dat", mem);
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/singlecycleMIPS/singlecycleMIPS-lite-commented/initReg.dat", registerfile);

    for(i=0; i<31; i=i+1)
    $display("Instruction Memory[%0d]= %h  Data Memory[%0d]= %h   Register[%0d]= %h", i, mem[i], i, datmem[i], i, registerfile[i]);
end

initial
begin
pc = 0;
#400 $finish;
end

initial
begin
clk = 0;
//40 time unit for each cycle
forever #20  clk = ~clk;
end

initial 
begin
$monitor($time," PC %h gout %h alu result %h out2 %h dataa %h, datab %h, datac %h out5 %h INST %h  swand=%b  MEM[12-15]=%h%h%h%h ", 
         pc, gout, sum, out2, dataa, datab,datac, out5, instruc[31:0], swand, datmem[12], datmem[13], datmem[14], datmem[15] );
end
endmodule
