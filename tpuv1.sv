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
    input [ADDRW-1:0] addr,
    output [DATAW-1:0] dataOut
);

logic signed [BITS_AB-1:0] Ain [DIM-1:0];
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic WrEnA, WrEnB, WrEnC, en;
logic [$clog2(DIM)-1:0] Arow, Crow;
logic signed [BITS_AB-1:0] Amid [DIM-1:0];
logic signed [BITS_AB-1:0] Bmid [DIM-1:0];
logic signed [BITS_C-1:0] Cin  [DIM-1:0];
logic signed [BITS_C-1:0] Cout [DIM-1:0];
logic matmul_rst;
logic matmul_en;
logic [$clog2(DIM*3)-1:0] matmul_cnt;

memA  #(.BITS_AB(BITS_AB), .DIM(DIM))
  memA (.clk(clk), .rst_n(rst_n), .en(en), .WrEn(WrEnA), .Ain(Ain), .Arow(Arow), .Aout(Amid));

memB  #(.BITS_AB(BITS_AB), .DIM(DIM))
  memB (.clk(clk), .rst_n(rst_n), .en(WrEnB || en), .Bin(Bin), .Bout(Bmid));

systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM))
             sA (.clk(clk), .rst_n(rst_n), .WrEn(WrEnC), .en(WrEnC || en),
                 .A(Amid), .B(Bmid), .Cin(Cin), .Crow(Crow), .Cout(Cout));

typedef enum {IDLE, MATMUL} state_t;
state_t curr_state, nxt_state;

assign WrEnA = (addr[15:8] == 8'h01) && r_w;
assign Arow = addr[5:3];
assign WrEnB = (addr[15:8] == 8'h02) && r_w;
assign Crow = addr[6:4];
assign Cin  = ~addr[3] ? {>>16{{>>{Cout[7:4]}}, dataIn}} : {>>16{dataIn, {>>{Cout[3:0]}}}};
assign WrEnC = (addr[15:8] == 8'h03) && r_w;
assign Ain = {>>8{dataIn}};
assign Bin = (WrEnB) ? {>>8{dataIn}} : {>>8{64'sh0000000000000000}};
assign dataOut  = {>>{addr[3] ? Cout[7:4] : Cout[3:0]}};

always_comb begin
  en = 0;
  matmul_en = 0;
  matmul_rst = 1;
  nxt_state = IDLE;
  case (curr_state)
    MATMUL: begin
      matmul_rst = 0;
      matmul_en = 1;
      en = 1;
      if (matmul_cnt == (DIM*3-2))
        nxt_state = IDLE;
      else
        nxt_state = MATMUL;
      end
      default: begin
        if (addr == 16'h0400 && r_w)
          nxt_state = MATMUL;
      end
  endcase
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    curr_state <= IDLE;
  end else
    curr_state <= nxt_state;
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n)
   matmul_cnt <= '0;
  else if (matmul_rst)
   matmul_cnt <= '0;
  else if (matmul_en)
   matmul_cnt <= matmul_cnt + 1;
end

endmodule