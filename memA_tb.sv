// memB testbench

`include "systolic_array_tc.svh"

module memA_tb();

  localparam BITS_AB=8;
  localparam BITS_C=16;
  localparam DIM=8;
  localparam ROWBITS=$clog2(DIM);

  localparam TESTS=10;
   
  logic clk, rst_n, en, WrEn;
  logic [ROWBITS-1:0] Crow;
  logic signed [BITS_AB-1:0] Ain  [DIM-1:0];
  logic signed [BITS_AB-1:0] Aout [DIM-1:0];

  integer mycycle;

  memA #(.BITS_AB(BITS_AB), .DIM(DIM)) 
     memDUT(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(WrEn), .Ain(Ain), .Aout(Aout));

  //systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) DUT (.*);
  systolic_array_tc #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) satc;

  integer errors, mycycles;
  bit signed [BITS_AB-1:0] Atest;    // Temporarily store get_next_A

  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    en    = 1'b0;
    WrEn  = 1'b0;
    errors = 0;

    // reset input
    for(int rowcol=0; rowcol < DIM; ++rowcol) begin
        Ain[rowcol] = {BITS_AB{1'b0}};
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
                Aout[rowcol] = satc.get_next_A(rowcol);
            end
            @(posedge clk) begin end
            mycycle = satc.next_cycle();
        end
         
        @(posedge clk) begin end
        // compute is done
        en = 1'b0;
 
        // reset input
        for(int rowcol = 0; rowcol < DIM; ++rowcol) begin
            Ain[rowcol] = {BITS_AB{1'b0}};
        end

        // check against test case
        for(int rowcol = 0; rowcol < DIM; ++rowcol) begin
            Atest = satc.get_next_A(rowcol);
            if (Atest !== Aout[rowcol]) begin
                errors++;
            end
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
