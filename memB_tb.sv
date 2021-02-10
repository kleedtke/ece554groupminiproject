module memB_tb();


logic clk, rst_n, en;
logic signed [7:0][7:0] Bin;
logic signed [7:0][7:0] Bout;



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

		


	end


end


always #5 clk = ~clk; 




endmodule
