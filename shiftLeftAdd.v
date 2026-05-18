module shiftLeftAdd(shout,shin);
output [27:0] shout;
input [25:0] shin;
assign shout={shin, 2'b00};
endmodule
