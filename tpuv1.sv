module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
    )
   (
    input  clk, rst_n, r_w, // r_w=0 read, =1 write
    input  [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input  [ADDRW-1:0] addr
   );

  logic signed [BITS_AB-1:0] Ain [DIM-1:0];
  logic signed [BITS_AB-1:0] Bin [DIM-1:0];
  logic signed [BITS_C-1:0] Cin [DIM-1:0];
  logic [$clog2(DIM)-1:0] Crow;
  logic [2:0] Arow;

  logic signed[BITS_AB-1:0] A_memTo_array [DIM-1:0];
  logic signed[BITS_AB-1:0] B_memTo_array [DIM-1:0];
  logic signed[BITS_C-1:0] C_memTo_array [DIM-1:0];

  logic WrEnA, WrEnB, WrEnC, en;

  logic [$clog2(DIM*3)-1:0] matmul;
   
  systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM))
  	  sa(.clk(clk), .rst_n(rst_n), .WrEn(WrEnC), .en(en), .A(A_memTo_array), .B(B_memTo_array), .Cin(Cin), .Crow(Crow), .Cout(C_memTo_array));

  memA #(.BITS_AB(BITS_AB), .DIM(DIM)) // not sure about Arow
      mA(.clk(clk), .rst_n(rst_n), .WrEn(WrEnA), .en(en), .Ain(Ain), .Arow(Arow), .Aout(A_memTo_array));

  memB #(.BITS_AB(BITS_AB), .DIM(DIM))
      mB(.clk(clk), .rst_n(rst_n), .en(WrEnB || en), .Bin(Bin), .Bout(B_memTo_array));

  // MMIO Address		R/W		TPUv1 location
  // 0x0100 - 0x013f		W		A[0][0], A[0][1], ... A[7][7]
  // 0x0200 - 0x023f		W		B[0][0], B[0][1], ... B[7][7]
  // 0x0300 - 0x037f		R & W		C[0][0], C[0][1], ... C[7][7]
  // 0x0400			W		MatMul (start systolic array computation)

  assign WrEnA = ((addr[15:8] == 8'h01) && r_w);
  assign WrEnB = ((addr[15:8] == 8'h02) && r_w);
  assign WrEnC = ((addr[15:8] == 8'h03) && r_w);
  
  assign Arow = addr[5:3];
  assign Crow = addr[6:4];

  typedef enum {IDLE, MATMUL} state;
  state curr_state, next_state;

  assign {>>{Ain}} = dataIn;
  assign {>>{Bin}} = dataIn;
  //assign {>>{Cin[7:0]}} = dataIn; 
  //assign {>>{Cin[15:8]}} = dataIn;
  assign {>>{Cin}}  = addr[6] ? {dataIn, {>>{C_memTo_array[7:4]}}} : {{>>{C_memTo_array[3:0]}}, dataIn}; 
  assign dataOut = C_memTo_array[Crow];


  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
	curr_state <= IDLE;
    end else
	curr_state <= next_state;
  end

  always_comb begin
    en = 0;
    next_state = IDLE;
    case (curr_state)
        MATMUL: begin
            en = 1;
	        matmul = matmul + 1;
            if (matmul == (DIM*3 - 2))
                next_state = IDLE;
            else
                next_state = MATMUL;
        end
        default: begin
            matmul = 0;
            if (addr == (16'h0400 && r_w))
                next_state = MATMUL;
        end
    endcase
  end



endmodule
