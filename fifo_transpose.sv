module fifo_transpose
  #(
    parameter DEPTH=8,
    parameter BITS=64
   )
   (
    input clk,rst_n,en,WrEn,
    input [BITS-1:0] d [DEPTH-1:0],
    output [BITS-1:0] q
   );

  logic [BITS-1:0] buf [DEPTH-1:0];
  assign q = buf[0];

  integer i;
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin
        for (i = 0; i < DEPTH; i++)
            buf[i] <= 0;
    end else if (WrEn) begin // write vals at input to internal buffer
      for (i = 0; i < DEPTH; i++)
          buf[i] <= d[i];
    end else if (en) begin // shift out vals
      for (i = 0; i < DEPTH - 1; i++) begin
          buf[i] <= buf[i + 1];
      end
      buf[DEPTH - 1] <= 0; // clear last element
    end

endmodule
