module comparator32(
    output gt,  // Greater Than (a > b)
    output lt,  // Less Than (a < b)
    output eq,  // Equal (a == b)
    input [31:0] a,
    input [31:0] b
);

    // Her bir ç?k?? için mant?ksal kar??la?t?rma:
    assign gt = (a > b);
    assign lt = (a < b);
    assign eq = (a == b);

endmodule
