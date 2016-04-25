module mem_control( reset,
					wren_ctl,
					rden_ctl,
					rden_vga,
					addr_vga,
					addr_ctl,
					ready_vga,
					ready_ctl,
					data_c_m,
					q,
					q_in,
					q_out,
					w_en,
					addr,
					r_en,
					clk_m,
					clk
					);

input				reset, clk, rden_vga, rden_ctl, wren_ctl;
input [1:0]			q, q_in;
input [5:0] 		addr_vga, addr_ctl;

output reg 			ready_vga, ready_ctl, clk_m, r_en, w_en;
output reg [1:0]	q_out;
output reg [13:0]	data_c_m;
output reg [5:0] 	addr;

///////////////////////////////////////////////////

reg					who_rd_from;
reg [2:0]			k;
reg [1:0] 			vetor[6:0];
parameter			IDLE			= 0,
					CONFIG_RD 		= 1,
					READ			= 2,
					TRANSFER		= 3,
					READY			= 4,
					CONFIG_WR		= 5,
					WRITE			= 6,
					SEND_DATA		= 7,
					CONFIG_DEST		= 8,
					//INCREMENT		= 9,
					WRITE_D			= 10,
					FADE			= 11,
					CHECK			= 12;

///////////////////////////////////////////////////

reg [3:0]			state;
reg	[3:0]			next_state;

///////////////////////////////////////////////////

assign estado = state;

// decodificador de proximo estado
always @ (*)
begin
	case(state)
		//
		IDLE:
		begin
			if (rden_vga == 1)
				next_state = CONFIG_DEST;
			else if(rden_ctl == 1)
				next_state = CONFIG_DEST;
			else if (wren_ctl == 1)
				next_state = CONFIG_WR;
			else 
				next_state = IDLE;
		end
		//
		CONFIG_DEST : next_state = CONFIG_RD;
		//
		CONFIG_RD : next_state = READ;
		//
		READ : next_state = TRANSFER;
		//
		TRANSFER: next_state = CHECK;
		//
		CHECK:
		begin
			if (k == 7)
				next_state = SEND_DATA;
			else
				next_state = CONFIG_RD;
		end
		//
		SEND_DATA : next_state = READY;
		//
		CONFIG_WR : next_state = WRITE;
		//
		WRITE : next_state = WRITE_D;
		//
		WRITE_D : next_state = FADE;
		//
		FADE : next_state = IDLE;
		//
		READY : next_state = IDLE;
		//
		default: next_state = IDLE;
		//
	endcase
end

///////////////////////////////////////////////////

//memoria
always @ (posedge clk)
begin
	if (!reset)
	begin
		state <= IDLE;
		vetor[0] <= 0;
		vetor[1] <= 0;
		vetor[2] <= 0;
		vetor[3] <= 0;
		vetor[4] <= 0;
		vetor[5] <= 0;
		vetor[6] <= 0;
		k <= 0;
		who_rd_from <= 0;
	end
	else
	begin
		state <= next_state;
		vetor[0] <= vetor[0];
		vetor[1] <= vetor[1];
		vetor[2] <= vetor[2];
		vetor[3] <= vetor[3];
		vetor[4] <= vetor[4];
		vetor[5] <= vetor[5];
		vetor[6] <= vetor[6];
		k <= k;
		who_rd_from <= who_rd_from;
		if(state == IDLE)
		begin
			k <= 0;
		end
		else if(state == TRANSFER) // mudar para SEND_READ se der ruim ou testar com negedge
		begin
			vetor[k-1] <= q;
		end
		else if(state == CONFIG_DEST)
		begin
			if(rden_vga == 1)
				who_rd_from <= 1;
			else
				who_rd_from <= 0;
		end
		else if(state == CHECK)
		begin
			if(k != 7)
				k <= k + 1;
		end
	end
end

///////////////////////////////////////////////////

// decodificador de saida
always @ (*)
begin
	r_en = 0;
	w_en = 0;
	addr = 0;
	clk_m = 0;
	ready_vga = 0;
	ready_ctl = 0;
	data_c_m = 0;
	q_out = 0;
	case(state)
		//
		//IDLE:
		//
		CONFIG_RD:
		begin
			if(who_rd_from == 1)
				addr = addr_vga + k;
			else
				addr = addr_ctl + k;
			r_en = 1;
			w_en = 0;
			clk_m = 0;
		end
		//
		READ:
		begin
			if(who_rd_from == 1)
				addr = addr_vga + k;
			else
				addr = addr_ctl + k;
			r_en = 1;
			w_en = 0;
			clk_m = 1;
		end
		//
		TRANSFER:
		begin
			if(who_rd_from == 1)
				addr = addr_vga + k;
			else
				addr = addr_ctl + k;

			r_en = 1;
			w_en = 0;
			clk_m = 0;
		end
		//
		SEND_DATA:
		begin
			{data_c_m[1], data_c_m[0]} = vetor[0];
			{data_c_m[3], data_c_m[2]} = vetor[1];
			{data_c_m[5], data_c_m[4]} = vetor[2];
			{data_c_m[7], data_c_m[6]} = vetor[3];
			{data_c_m[9], data_c_m[8]} = vetor[4];
			{data_c_m[11], data_c_m[10]} = vetor[5];
			{data_c_m[13], data_c_m[12]} = vetor[6];
		end
		READY:
		begin
			{data_c_m[1], data_c_m[0]} = vetor[0];
			{data_c_m[3], data_c_m[2]} = vetor[1];
			{data_c_m[5], data_c_m[4]} = vetor[2];
			{data_c_m[7], data_c_m[6]} = vetor[3];
			{data_c_m[9], data_c_m[8]} = vetor[4];
			{data_c_m[11], data_c_m[10]} = vetor[5];
			{data_c_m[13], data_c_m[12]} = vetor[6];
			if(who_rd_from == 1)
				ready_vga = 1;
			else
				ready_ctl = 1;
		end
		//
		CONFIG_WR:
		begin
			addr =  addr_ctl;
			r_en =  1'b0;
			w_en =  1'b1;
			clk_m = 1'b0;
			q_out = q_in;
		end
		//
		WRITE:
		begin
			addr =  addr_ctl;
			r_en =  1'b0;
			w_en =  1'b1;
			clk_m = 1'b1;
			q_out = q_in;
			//ready_ctl = 1'b1;
		end
		//
		WRITE_D: // caso ele demore mais de um pulso para dar write
		begin
			addr =  addr_ctl;
			r_en =  1'b0;
			w_en =  1'b1;
			clk_m = 1'b1;
			q_out = q_in;
			//ready_ctl = 1'b1;
		end
		//
		FADE:	// caso o clk_m NÃO seja desativado por ultimo.
		begin
			addr =  addr_ctl;
			r_en =  1'b0;
			w_en =  1'b1;
			clk_m = 1'b0;
			q_out = q_in;
			ready_ctl = 1'b1;
		end
		//
		CONFIG_DEST:
		begin
			clk_m = 1;
		end
		//
		default:
		begin
			r_en = 0;
			w_en = 0;
			addr = 0;
			clk_m = 0;
			ready_vga = 0;
			ready_ctl = 0;
			data_c_m = 0;
		end
	endcase
end

endmodule