module memA
  #(
    parameter BITS_AB=8,
    parameter DIM=8
   )
   (
    input clk,rst_n,en,WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
   );

  logic [BITS_AB-1:0] Atmp [DIM-1:1];
  logic [DIM-1:0] wr;

  fifo_transpose #(.BITS(BITS_AB))
                ft(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(wr[0]), .d(Ain), .q(Aout[0]));

  always_comb begin
    wr = 0;
    wr[Arow] = WrEn;
  end

  genvar i;
  generate
    for(i=1; i<DIM; i++) begin
      fifo_transpose #(.BITS(BITS_AB))
                     t(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(wr[i]), .d(Ain), .q(Atmp[i]));
      fifo #(.DEPTH(i),.BITS(BITS_AB)) 
           f(.clk(clk), .rst_n(rst_n), .en(en), .d(Atmp[i]), .q(Aout[i]));
    end
  endgenerate

endmodule
