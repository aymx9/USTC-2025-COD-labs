module COMP (
    input                   [ 31: 0]        a, b,
    output                  [  0: 0]        ul,
    output                  [  0: 0]        sl
);

wire [31:0] s;
wire        ovf;

assign s = a - b;
assign ovf = (a[31] ^ b[31]) & (a[31] ^ s[31]);
assign ul  = (~a[31] & b[31]) | (~a[31] & s[31]) | (b[31] & s[31]);
assign sl  = (a[31] & ~b[31]) | (s[31] & ~ovf);

//a<b => 1

endmodule