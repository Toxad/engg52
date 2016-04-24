module infrared( 	w1,		// esquerda
                	w2, 		// direita
                	w3, 		// select
                	w4,		// reset
                	clk,
                  E,
                	reset
						//estado,
						//i_out,
						//reg_E_out
                	);

input       		reset, clk, E;
output reg			w1, w2, w3, w4;
//output [2:0]		estado;
//output [5:0]		i_out;
//output [31:0]		reg_E_out;

////////////////////////////////////////////////////////

parameter		idle  = 0,
					Recebe = 1,
					Aceita = 2,
					Teste  = 3,
					Prolonga = 4;
  
reg[31:0]		reg_E;
reg[2:0] 		state, next_state;
reg[5:0]       i;

////////////////////////////////////////////////////////

//assign estado = state;
//assign reg_E_out = reg_E;
//assign i_out = i;

// decodificador de proximo estado
always @ (*)
begin
	case(state)
		idle:
		begin
      if (E == 0)
				next_state = Recebe;
      else
				next_state = idle;
		end
		//
		Recebe:	
		begin
      if (i > 0)
			next_state = Recebe;
      else if (i == 0)
			next_state = Aceita;
      else
          next_state = idle;
		end
		//
		Aceita:
		begin
      if(reg_E[7] == !reg_E[15] &&
			reg_E[6] == !reg_E[14] &&
			reg_E[5] == !reg_E[13] &&
			reg_E[4] == !reg_E[12] &&
			reg_E[3] == !reg_E[11] &&
			reg_E[2] == !reg_E[10] &&
			reg_E[1] == !reg_E[9] &&
			reg_E[0] == !reg_E[8]
			)
					next_state = Teste;
      else
        	next_state = idle;
		end
		//
		Teste: next_state = Prolonga;
		//
		Prolonga: next_state = idle;
		//
		default: next_state = idle;
	endcase
end

////////////////////////////////////////////////////////

// memoria
always @ (posedge clk)
begin
	if (!reset)
	begin
		state <= idle;
		 reg_E <= 0;
		 i <= 31;
	end
	else
	begin
		state <= next_state;
    if(state == Recebe)
		begin
      reg_E[i] <= E;
		if(i > 0)
			i = i-1;
		else
			i = i;
		end
    else if(state == idle)
    begin
      reg_E <= 0;
    	i <= 31;
    end
    else
  	begin
      reg_E <= reg_E;
      i <= 31;
    end
	end
end

////////////////////////////////////////////////////////

// decodificador de saida
always @ (*)
begin
	case(state)
		Teste:
		begin
      if (reg_E[7:0] == 8'b11110011) // 12 reset 
        begin
				w1 = 1;
				w2 = 1;
				w3 = 1;
				w4 = 1;
        end
      else if (reg_E[7:0] == 8'b11110001) // 14 esquerda
        begin
				w1 = 0;
				w2 = 1;
				w3 = 1;
				w4 = 0;
        end
      else if (reg_E[7:0] == 8'b11101101)  // 17 direita
        begin
				w1 = 1;
				w2 = 0;
				w3 = 1;
				w4 = 0;
        end
      else if (reg_E[7:0] == 8'b11101110) // 18 select
        begin
				w1 = 1;
				w2 = 1;
				w3 = 0;
				w4 = 0;
        end
      else
        begin
        w1 = 1;
        w2 = 1;
        w3 = 1;
        w4 = 0;
        end
		end
		//
		default:
		begin
			w1 = 1;
			w2 = 1;
			w3 = 1;
			w4 = 0;
		end
	endcase
end

endmodule