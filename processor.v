module processor;
reg [31:0] pc; //32-bit program counter
reg clk; //clock

// 128 byte data and instruction memory
reg [7:0] datmem[0:127], mem[0:127]; 
reg [2:0] status; // status[2]=V, status[1]=N, status[0]=Z

wire [31:0] 
dataa,      //Read data 1 output of Register File
datab,      //Read data 2 output of Register File
datac,      //Read data 3 output of Register File 
out2,       //Output of mux with ALUSrc control-mult2
out3,       //Output of mux with MemToReg control-mult3
out4,       //Output of mux with (Branch&ALUZero) control-mult4
out5,       //Output of swand Data Memory MUX
result,     //ALU result
mem_addr;   // actual address going to data memory
extad,      //Output of sign-extend unit
adder1out,  //Output of adder which adds PC and 4-add1
adder2out,  //Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,     //Output of shift left 2 unit
sextshamt,  //Output of sign_extend of shamt
j_target,   //J-Type target address
next_pc,    //Next PC address after Jump MUX
swinc_add_out; // out of adder for swinc 

wire [27:0] shlAdd;  // 28 bit branch offset

wire [5:0] inst31_26;   //31-26 bits of instruction
wire [5:0] 
inst25_21,  //25-21 bits of instruction
inst20_16,  //20-16 bits of instruction
inst10_6,   //10-6 bits of instruction
inst15_11;  //15-11 bits of instruction

wire [4:0] out1; // Write Register address and output of mux-1
wire [15:0] inst15_0;   //15-0 bits of instruction
wire [25:0] inst25_0; // 25-0 bits of instruction

wire [31:0] instruc,    //current instruction
dpack;          //Read data output of memory (data read from memory)

wire [2:0] gout;    //Output of ALU control unit
wire zout, nout, vout, gt, lt, eq, pcsrc, lt_and_lwslt; // Control flags

//Control signals
wire regdest, alusrc, beqm, lwslt, swand, swinc, swv, bnpos, regwrite, memread, memwrite, branch, aluop1, aluop0;
wire [1:0] memtoreg;
wire newmemwrite;
wire use_shamt, ifBeqm;

wire bnpos_cond;        
wire do_bnpos_branch;   
wire balerr_cond, do_balerr_branch, do_j_branch;
wire swv_memwrite;
//32-size register file
reg [31:0] registerfile[0:31];
integer i;

// Status Register Guncelleme
always @(posedge clk) begin
    status <= {vout, nout, zout};
end

// datamemory connections
always @(posedge clk)
if (newmemwrite)
begin    
    datmem[mem_addr[6:0]+3] = out5[7:0];
    datmem[mem_addr[6:0]+2] = out5[15:8];
    datmem[mem_addr[6:0]+1] = out5[23:16];
    datmem[mem_addr[6:0]]   = out5[31:24];   
end

//instruction memory assignments
assign instruc = {mem[pc[6:0]], mem[pc[6:0]+1], mem[pc[6:0]+2], mem[pc[6:0]+3]};
assign inst31_26 = instruc[31:26];
assign inst25_21 = instruc[25:21];
assign inst20_16 = instruc[20:16];
assign inst15_11 = instruc[15:11];
assign inst10_6  = instruc[10:6];
assign inst15_0  = instruc[15:0];
assign inst25_0  = instruc[25:0];

// registers
assign dataa = registerfile[inst25_21]; 
assign datab = registerfile[inst20_16]; 
assign datac = registerfile[inst15_11]; 

always @(posedge clk)
 registerfile[out1] = regwrite ? out3 : registerfile[out1]; 

//read data from memory
assign dpack = {datmem[mem_addr[6:0]], datmem[mem_addr[6:0]+1], datmem[mem_addr[6:0]+2], datmem[mem_addr[6:0]+3]};


// Calculate the jump address
assign j_target = {adder1out[31:28], shlAdd};

// multiplexers-> Control signals order: {s0},{s1,s0}  
mult3_to_1_5  mult1(out1, instruc[20:16], instruc[15:11], 5'd31, balerr, regdest);  
mult3_to_1_32 mult2(out2, datab, extad, sextshamt, use_shamt, alusrc);  
mult4_to_1_32 mult3(out3, result, dpack, {31'b0, lt_and_lwslt},adder1out, memtoreg[1], memtoreg[0]);    
mult3_to_1_32 mult4(out4, adder1out, adder2out, datac, ifBeqm, pcsrc);  
mult3_to_1_32 mult5(out5, datab, datac, swinc_add_out, swinc, swand);   
mult2_to_1_32 mult6(next_pc, out4, j_target, do_j_branch);
mult2_to_1_32 mult7(mem_addr, result, dataa, swv);

// load pc
always @(negedge clk)
pc = next_pc;

// comparision
comparator32 comp1(gt, lt, eq, datab, dpack);

//ALU unit
alu32 alu1(result, dataa, out2, zout,nout,vout, gout);

//adder which adds PC and 4
adder add1(pc, 32'h4, adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out, sextad, adder2out);

//adder which adds Read Data 2 ($rt) and constant 1 for swinc
adder add3(datab, 32'h1, swinc_add_out);

// Control unit
control cont(
    instruc[31:26], 
    instruc[5:0], 
    regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch,
    aluop1, aluop0, use_shamt,
    lwslt, beqm, swand, swinc,
    swv, bnpos, balerr
);

//Sign extend unit of immediate
signext sext(instruc[15:0], extad);

//sign_extend unit of shamt
signExtend5_to_32 sext2(instruc[10:6], sextshamt);

//ALU control unit
alucont acont(aluop1, aluop0, instruc[5], instruc[4], instruc[3], instruc[2], instruc[1], instruc[0], gout);

//Shift-left 2 for J-type target (inst[25:0] -> 28 bit)
shiftLeftAdd shift(shlAdd, inst25_0);

//Shift-left 2 for branch offset (sign-extended immediate)
shift shift2(sextad, extad);

//Gates
assign pcsrc = branch && zout;

assign swv_memwrite = !swv || status[2];

assign newmemwrite = memwrite && swv_memwrite;

assign ifBeqm = beqm && eq;

assign lt_and_lwslt = lt && lwslt; 

//Status[Z] or Status[N]
assign bnpos_cond = status[0] | status[1]; 

assign do_bnpos_branch = bnpos & bnpos_cond;

//Status[Z] and Status[N] and Status[V]
assign balerr_cond = status[0] & status[1] & status[2]; 

assign do_balerr_branch = balerr & balerr_cond;

assign do_j_branch = do_bnpos_branch | do_balerr_branch;

//initialize data memory,instruction memory and registers
initial
begin
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/SingleCycleMIPS/initDm.dat", datmem); 
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/SingleCycleMIPS/initIM.dat", mem);
$readmemh("C:/Users/Lenovo/Documents/Projeler/CompOrg2/SingleCycleMIPS/initReg.dat", registerfile);

//Content of memories and register file
for(i=0; i<31; i=i+1)
    $display("Instruction Memory[%0d]= %h  Data Memory[%0d]= %h   Register[%0d]= %h", i, mem[i], i, datmem[i], i, registerfile[i]);
end

initial
begin
pc = 0;
//assign status register
//status = 3'b111;
#400 $finish;
end

initial
begin
clk = 0;
forever #20  clk = ~clk;
end

initial 
begin
$monitor($time," PC %h  INST %h  STAT=%b  do_j=%b  MEM[8]=%h  MEM[12]=%h", //Test statements
         pc, instruc[31:0], status, do_j_branch, 
         {datmem[8], datmem[9], datmem[10], datmem[11]},
         {datmem[12], datmem[13], datmem[14], datmem[15]});
end
endmodule
