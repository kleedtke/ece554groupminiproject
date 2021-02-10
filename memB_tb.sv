// memB testbench

`include "systolic_array_tc.svh"

module memB_tb();

  localparam BITS_AB=8;
  localparam BITS_C=16;
  localparam DIM=8;
  localparam ROWBITS=$clog2(DIM);

  localparam TESTS=10;
   
  logic clk, rst_n, en, WrEn;
  logic [ROWBITS-1:0] Crow;
  logic signed [BITS_AB-1:0] Bin  [DIM-1:0];
  logic signed [BITS_AB-1:0] Bout [DIM-1:0];

  memB #(.BITS_AB(BITS_AB), .DIM(DIM)) 
     DUT(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(WrEn), .Bin(Bin), .Bout(Bout));

  systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) DUT (.*);
  systolic_array_tc #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) satc;

  integer errors, mycycles;
  bit signed [BITS_AB-1:0] Btest;    // Temporarily store get_next_B

  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    en    = 1'b0;
    WrEn  = 1'b0;
    errors = 0;

    // reset input
    for(int rowcol=0; rowcol < DIM; ++rowcol) begin
        Bin[rowcol] = {BITS_AB{1'b0}};
    end

    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    for (int test = 0; test < TESTS; ++test) begin
        // initialize test case
        satc = new();

	@(posedge clk) begin end
	en = 1'b1;

	// DIM cycles to fill, DIM cycles to compute, DIM cycles to drain
        for(int cyc=0;cyc<(DIM*3-2);++cyc) begin
            // set B values from the testcase
            for(int rowcol = 0; rowcol < DIM; ++rowcol) begin
                Bout[rowcol] = satc.get_next_B(rowcol);
            end
            @(posedge clk) begin end
            mycycle = satc.next_cycle();
        end
         
        @(posedge clk) begin end
        // compute is done
        en = 1'b0;
 
        // reset input
        for(int rowcol = 0; rowcol < DIM; ++rowcol) begin
            Bin[rowcol] = {BITS_AB{1'b0}};
        end

        // check against test case
        for(int rowcol = 0; rowcol < DIM; ++rowcol) begin
            Btest = satc.get_next_B(col);
            if (Btest !== Bout[rowcol]) begin
                errors++;
            end
        end


    // check errors
    if (errors > 0)
        $display("Errors found: %d", errors);
    else
        $display("Test passed");

    $stop;
  
  end

always #5 clk = ~clk;

endmodule
