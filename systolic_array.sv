module systolic_array
#(
   parameter BITS_AB=8,
   parameter BITS_C=16,
   parameter DIM=8
   )
  (
   input                      clk,rst_n,WrEn,en,
   input signed [BITS_AB-1:0] A [DIM-1:0],
   input signed [BITS_AB-1:0] B [DIM-1:0],
   input signed [BITS_C-1:0]  Cin [DIM-1:0],
   input [$clog2(DIM)-1:0]    Crow,
   output signed [BITS_C-1:0] Cout [DIM-1:0]
   );

   logic signed [BITS_AB-1:0] Asums [DIM-1:0] [DIM:0];
   logic signed [BITS_AB-1:0] Bsums [DIM:0] [DIM-1:0];
   logic signed [BITS_C-1:0] Csums [DIM-1:0] [DIM-1:0];

    genvar i, j;

    generate
       for (i=0; i<DIM; i=i+1) begin
            for (j=0; j<DIM; j=j+1) begin
                tpumac #(.BITS_AB(BITS_AB), 
                         .BITS_C(BITS_C)) 
                    tpu (.clk(clk), 
                         .rst_n(rst_n), 
                         .WrEn((i == Crow) && WrEn), 
                         .en(en), 
                         .Ain(Asums[i][j]), 
                         .Bin(Bsums[i][j]), 
                         .Cin(Cin[j]), 
                         .Aout(Asums[i][j+1]), 
                         .Bout(Bsums[i+1][j]), 
                         .Cout(Csums[i][j]));
            end
        end
    endgenerate

    always_comb begin
        for (int i=0; i<DIM; i=i+1) begin
            Asums[i][0] = A[i];
            Bsums[0][i] = B[i];
        end
    end

    assign Cout = Csums[Crow];


endmodule
