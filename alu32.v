module alu32(result,a,b,zout,nout,vout,gin);//ALU operation according to the ALU control line values
output [31:0] result;
input [31:0] a,b; 
input [2:0] gin;//ALU control line
reg [31:0] result;
reg [31:0] less;
output zout;
output nout;
output vout;
reg zout;
reg nout;
reg vout;
always @(a or b or gin)
begin
        vout = 0;
	case(gin)
	3'b010: begin
            result=a+b; 		//ALU control line=010, ADD
	    vout = (a[31] == b[31]) & (result[31] != a[31]);
            end
	3'b110: begin
            result=a+1+(~b);	//ALU control line=110, SUB
            vout = (a[31] != b[31]) & (result[31] != a[31]); 
            end
	3'b111: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) result=1;	
			else result=0;
		  end
	3'b000: result=a & b;	//ALU control line=000, AND
	3'b001: result=a|b;		//ALU control line=001, OR
	default: result=31'bx;	
	endcase
zout=~(|result);
nout=result[31];
end
endmodule
