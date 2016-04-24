`timescale 1ns/1ps
module infrared_tb();
reg       			reset, clk, E;
wire				w1, w2, w3, w4;
wire [2:0] estado;
wire [5:0] i_out;
wire [31:0] reg_E_out;


infrared tb_inst
(
  .w1(w1),
  .w2(w2),
  .w3(w3),
  .w4(w4),
  .reset(reset),
  .clk(clk),
  .E(E),
  .estado(estado),
  .i_out(i_out),
  .reg_E_out(reg_E_out)
);

always
	#20 clk = ~clk;
initial
begin
  //tem q mudar isso ai tbm
  clk = 0;
  
  $monitor("TEMPO:%d w1:%d w2:%d w3:%d w4:%d estado:%d i:%d reg_E:%d",
	$time,w1,w2,w3,w4, estado, i_out, reg_E_out);

  reset = 0;

  #20 reset = 1;
  
  #40  E=0; // inicio
  
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=0;
  #41 E=1;
  #41 E=1;
  #41 E=0;
  #41 E=0;
  
  #41 E=1;
  #41 E=1;
  #41 E=1;
  #41 E=1;
  #41 E=0;
  #41 E=0;
  #41 E=1;
  #41 E=1;


	#2000 $stop;
end

endmodule
	