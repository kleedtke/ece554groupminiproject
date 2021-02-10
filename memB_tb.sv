module memB_tb();

localparam BITS_AB=8;
localparam DIM=8;

logic clk, rst_n, en;
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic signed [BITS_AB-1:0] Bout [DIM-1:0];



memB DUT(.clk(clk), .rst_n(rst_n), .en(en), .Bin(Bin), .Bout(Bout));



initial begin

	clk = 1'b0;
	rst_n = 1'b0;
	en = 1'b0;
	
	#25; 
	rst_n = 1'b1;

	

	en = 1'b1;

	#5;

	for(integer i = 0; i < 8; i++)begin

		Bin[i] = $random();


	end

	#25;

	$stop;

end


always #5 clk = ~clk; 




endmodule
