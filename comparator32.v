module comparator32(
    output gt,  // Greater Than (a > b)
    output lt,  // Less Than (a < b)
    output eq,  // Equal (a == b)
    input [31:0] a,
    input [31:0] b
);

    
    assign gt = ($signed(a) > $signed(b));
    assign lt = ($signed(a) < $signed(b));
    assign eq = (a == b);

endmodule
