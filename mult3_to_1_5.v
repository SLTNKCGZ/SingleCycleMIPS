module mult3_to_1_5(out, i0,i1,i2,s1,s0);
output [4:0] out;
input [4:0] i0, i1, i2;
input s1, s0;
assign out = ({s1, s0} == 2'b00) ? i0 :
             ({s1, s0} == 2'b01) ? i1 :
             ({s1, s0} == 2'b10) ? i2 : 5'bx;
endmodule
