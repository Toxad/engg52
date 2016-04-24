module vga(			data,		// data recebida do controlador de memoria (vector de 7 posições)
					ready,		// ready para confirmar a chegada de dados
					addr,		// endereço para o controlador de memoria (vector de 6 posições)
					rden,		// read enable
					rst,		// reset
					pl_signal,	// jogador
					col_signal,	// coluna atual
					vga_r,		// vga red
					vga_g,		// vga green
					vga_b,		// vga blue
					hsync,		// horizontal sync
					vsync,		// vertical sync
					blank,		// blank
					roger_that, // Roger that, sir!
					clk 		// clock 25Mhz
			);	

input				clk, rst, ready;
input				pl_signal;
input				col_signal;
input [13:0]		data;

output 				hsync, vsync, blank;
output reg 			rden, roger_that;
output reg [5:0] 	addr;
output reg [7:0] 	vga_r, vga_g, vga_b;

////////////////////////////////////////////////////////

reg 				grade, player1, player2, column;
reg [2:0]			actual_column;
reg [1:0]			actual_player;
reg [1:0] 			vector[6:0];
integer 			h_count;
integer 			v_count;

////////////////////////////////////////////////////////

reg [2:0] 			state, next_state;
parameter			idle = 0,
					calc_addr = 1,
					waiting = 2,
					copy_data = 3,
					change_p = 4,
					change_col = 5;

////////////////////////////////////////////////////////

assign hsync = (h_count <= 95) ? 1'b0 : 1'b1;
assign vsync = (v_count <= 1) ? 1'b0 : 1'b1;
assign blank = (h_count > 143 & h_count <= 783 & v_count > 35 & v_count <= 515) ? 1'b1 : 1'b0;

////////////////////////////////////////////////////////

always @(posedge clk)
begin
	// estava if(rst)
	if(!rst) 
	begin
		h_count <= 0;
		v_count <= 0;
		//player1 <= 0;
		//player2 <= 0;
		//column <= 0;
	end
	else
	begin
		h_count <= h_count + 1;
		if(h_count == 800)
		begin
			h_count <= 0;
			v_count <= v_count + 1;

			if(v_count == 525)
			begin
				v_count <= 0;
			end
		end
	end
	grade <=	(((h_count >= 242 && h_count < 686) &&			// grades horizontais (7)
				 ((v_count >= 115 && v_count < 118) ||
				 (v_count >= 168 && v_count < 171) ||
				 (v_count >= 221 && v_count < 224) ||
				 (v_count >= 274 && v_count < 277) ||
				 (v_count >= 327 && v_count < 330) ||
				 (v_count >= 380 && v_count < 383) ||
				 (v_count >= 433 && v_count < 436)))
				 ||
				 ((v_count >= 115 && v_count < 436) &&		// grades verticais (8)
				 ((h_count >= 242 && h_count < 245) ||
				 (h_count >= 305 && h_count < 308) ||
				 (h_count >= 368 && h_count < 371) ||
				 (h_count >= 431 && h_count < 434) ||
				 (h_count >= 494 && h_count < 497) ||
				 (h_count >= 557 && h_count < 560) ||
				 (h_count >= 620 && h_count < 623) ||
				 (h_count >= 683 && h_count < 686)))
				 );

	player1 <= ((((h_count >= 250 && h_count < 300) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[0] == 1) ||
				(((h_count >= 313 && h_count < 363) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[1] == 1) ||
				(((h_count >= 376 && h_count < 426) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[2] == 1) ||
				(((h_count >= 439 && h_count < 489) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[3] == 1) ||
				(((h_count >= 502 && h_count < 552) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[4] == 1) ||
				(((h_count >= 565 && h_count < 615) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[5] == 1) ||
				(((h_count >= 628 && h_count < 678) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[6] == 1));

	player2 <= ((((h_count >= 250 && h_count < 300) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[0] == 2) ||
				(((h_count >= 313 && h_count < 363) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[1] == 2) ||
				(((h_count >= 376 && h_count < 426) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[2] == 2) ||
				(((h_count >= 439 && h_count < 489) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[3] == 2) ||
				(((h_count >= 502 && h_count < 552) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[4] == 2) ||
				(((h_count >= 565 && h_count < 615) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[5] == 2) ||
				(((h_count >= 628 && h_count < 678) && 
				((v_count >= 123 && v_count < 163) ||
				(v_count >= 176 && v_count < 216) ||
				(v_count >= 229 && v_count < 269) ||
				(v_count >= 282 && v_count < 322) ||
				(v_count >= 335 && v_count < 375) ||
				(v_count >= 388 && v_count < 428))) && vector[6] == 2));

	column <= ((v_count >= 106 && v_count < 111) && (
			((h_count >= 250 && h_count < 300) && actual_column == 0) ||
			((h_count >= 313 && h_count < 363) && actual_column == 1) ||
			((h_count >= 376 && h_count < 426) && actual_column == 2) ||
			((h_count >= 439 && h_count < 489) && actual_column == 3) ||
			((h_count >= 502 && h_count < 552) && actual_column == 4) ||
			((h_count >= 565 && h_count < 615) && actual_column == 5) ||
			((h_count >= 628 && h_count < 678) && actual_column == 6)
			));
end

////////////////////////////////////////////////////////

// grade: #4d4d4d; player1: #6b87ce; player2: #ce6b6b; fundo: #ebe6e6;
always @(*)
begin
	if(grade == 1)			// se for grade #4d4d4d
	begin
		vga_r = 77;
		vga_g = 77;
		vga_b = 77;

	end
	else if(player1 == 1)	// se for player1
	begin
		vga_r = 107;
		vga_g = 135;
		vga_b = 206;
	end
	else if(player2 == 1) 	// se for player2
	begin
		vga_r = 206;
		vga_g = 107;
		vga_b = 107;

	end
	else if(column == 1)
	begin
		// Caso tenha sistema de ficha diferente quando for coloca-la
		if(actual_player == 1) // player 2
		begin
			vga_r = 107;
			vga_g = 135;
			vga_b = 206;
		end
		else if(actual_player == 2)		// player 1
		begin
			vga_r = 206;
			vga_g = 107;
			vga_b = 107;
		end
		else
		begin
			vga_r = 77;
			vga_g = 77;
			vga_b = 77;
		end
	end
	else 					// se for fundo
	begin
		vga_r = 235;
		vga_g = 230;
		vga_b = 230;
	end
end

////////////////////////////////////////////////////////

// decodificador de proximo estado
always @(*)
begin
	next_state = state;
	case(state)
		idle:
		begin
			if(col_signal == 1)
				next_state = change_col;
			else if(pl_signal == 1)
				next_state = change_p;
			else if(((h_count > 0 && h_count < 10) && v_count == 115) ||
				((h_count > 0 && h_count < 10) && v_count == 168) ||
				((h_count > 0 && h_count < 10) && v_count == 221) ||
				((h_count > 0 && h_count < 10) && v_count == 274) ||
				((h_count > 0 && h_count < 10) && v_count == 327) ||
				((h_count > 0 && h_count < 10) && v_count == 380))
				next_state = calc_addr; //calc_addr
			else
				next_state = idle;
		end
		calc_addr: next_state = waiting;
		change_col: next_state = idle;
		change_p: next_state = idle;
		waiting:
		begin
			if(ready == 1)
				next_state = idle;
			else 
				next_state = waiting;
		end
		//copy_data: next_state = idle;
		default: next_state = idle;
	endcase
end

////////////////////////////////////////////////////////

// memoria
always @(posedge clk)
begin
	if(!rst)
	begin
		state <= idle;
		actual_player <= 1;
		actual_column <= 0;
		vector[0] <= 0;
		vector[1] <= 0;
		vector[2] <= 0;
		vector[3] <= 0;
		vector[4] <= 0;
		vector[5] <= 0;
		vector[6] <= 0;
	end
	else
	begin
		state <= next_state;
		actual_column <= actual_column;
		actual_player <= actual_player;
		vector[0] <= vector[0];
		vector[1] <= vector[1];
		vector[2] <= vector[2];
		vector[3] <= vector[3];
		vector[4] <= vector[4];
		vector[5] <= vector[5];
		vector[6] <= vector[6];
		if(state == waiting)
		begin
			if(ready == 1)
			begin
				vector[0] <= {data[1], data[0]};
				vector[1] <= {data[3], data[2]};
				vector[2] <= {data[5], data[4]};
				vector[3] <= {data[7], data[6]};
				vector[4] <= {data[9], data[8]};
				vector[5] <= {data[11], data[10]};
				vector[6] <= {data[13], data[12]};
			end
		end
		else if(state == change_p)
		begin
			if(actual_player == 1)
				actual_player <= 2;
			else if(actual_player == 2)
				actual_player <= 1;
		end
		else if(state == change_col)
		begin
			if(actual_column < 6)
				actual_column <= actual_column + 1;
			else
				actual_column <= 0;
		end
	end
end

////////////////////////////////////////////////////////

// decodificador de saida
always @(*)
begin
	rden = 0;
	addr = 0;
	roger_that = 0;
	case(state)
		//
		calc_addr:
		begin
			rden = 0;
			if(h_count < 100 && v_count == 115)
				addr = 0;
			else if(h_count < 100 && v_count == 168)
				addr = 7;
			else if(h_count < 100 && v_count == 221)
				addr = 14;
			else if(h_count < 100 && v_count == 274)
				addr = 21;
			else if(h_count < 100 && v_count == 327)
				addr = 28;
			else if(h_count < 100 && v_count == 380)
				addr = 35;
		end
		//
		waiting:
		begin
			rden = 1;
			if(h_count < 100 && v_count == 115)
				addr = 0;
			else if(h_count < 100 && v_count == 168)
				addr = 7;
			else if(h_count < 100 && v_count == 221)
				addr = 14;
			else if(h_count < 100 && v_count == 274)
				addr = 21;
			else if(h_count < 100 && v_count == 327)
				addr = 28;
			else if(h_count < 100 && v_count == 380)
				addr = 35;
		end
		//
		change_col: roger_that = 1;
		//
		change_p: roger_that = 1;
		//
		default:
		begin
			rden = 0;
			addr = 0;
		end
	endcase
end
endmodule