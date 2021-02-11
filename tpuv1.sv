module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
    )
   (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
   );

logic [BITS_AB-1:0] A [DIM-1:0];
logic [BITS_AB-1:0] B [DIM-1:0];
logic [BITS_C-1:0]  Cin [DIM-1:0];
logic [$clog2(DIM)-1:0] Crow;
logic [BITS_AB-1:0] A_memTo_array [DIM-1:0];
logic [BITS_AB-1:0] B_memTo_array [DIM-1:0];

   
systolic_array
#(
   .BITS_AB(BITS_AB),
   .BITS_C(BITS_C),
   .DIM(DIM)
   )
  ourSystolic_array(
   .clk(clk), .rst_n(rst_n), .WrEn(r_w), .en(1'b1),
   .A(A_memTo_array), .B(B), .Cin(Cin),
   .Crow(Crow), .Cout(dataOut)
   );

memA
#(.BITS_AB(BITS_AB), .DIM(DIM))
  ourMemA(
	.clk(clk), .rst_n(rst_n), .WrEn(r_w), .en(1'b1),
	.Ain(A), .Arow(1'b0), .Aout(A_memTo_array));

memB
#(.BITS_AB(BITS_AB), .DIM(DIM))
  ourMemB(.clk(clk), .rst_n(rst_n), .en(1'b1), .Bin(B), .Bout(B_memTo_array));


endmodule
