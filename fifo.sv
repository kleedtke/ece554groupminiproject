// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo
  #(
  parameter DEPTH=8,
  parameter BITS=64
  )
  (
  input clk,rst_n,en,
  input [BITS-1:0] d,
  output reg [BITS-1:0] q
  );
  // your RTL code here
  reg [BITS-1:0] fifo [0:DEPTH-1];
  reg [7:0] ptr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      integer i;
      for (i=0; i<DEPTH; i=i+1) begin
        fifo[i] <= {BITS{1'b0}};
      end
      ptr <= 8'h00;
    end
    else begin
      if (en) begin
        fifo[ptr] <= d;
        ptr <= ((ptr+1) % (DEPTH));
      end
    end
  end

  assign q = fifo[ptr];

endmodule // fifo
