module main_control(reset,      // 1 bit   entrada
					response,   // 2 bits  saida pro modulo botão
					coluna_in,  // 3 bits  entrada (representa as 7 colunas)
					player_in,  // 2 bits  entrada (jogador 1 ou 2)
					active,     // 1 bit   entrada (sai do botao e vai pro main_control)
					addr,       // 6 bits  saida (vai para o controle de memoria)
					q,          // 2 bits  saida (vai para o controle de memoria)
					rden,       // 1 bit   saida (vai para o controle de memoria)
					wren,       // 1 bit   saida (vai para o controle de memoria)
					ready,       // 1 bit   entrada (vem do controle de memoria)
					data_in,
					clk  // clk
					); 

input               reset, active, ready, clk;
input [1:0]         player_in;
input [2:0]         coluna_in;
input [13:0]        data_in;
output reg [1:0]    response, q;
output reg [5:0]    addr;
output reg          rden, wren;

///////////////////////////////////////////

reg [3:0]           state, next_state;
reg [2:0]           coluna_atual;
reg [1:0]           player;
reg [1:0]           vetor[41:0];
reg                 player1_won, player2_won;
reg					fix;

///////////////////////////////////////////

integer             k; // de 0 a 5
integer             h;
parameter           IDLE = 0,
					RECEIVE = 1,
					CONFIG_RD = 2,
					WAIT_RD = 3,
					CHECK = 4,
					CONFIG_WR = 5,
					WAIT_WR= 6,
					GEN_RESP = 7,
					CHECK_VICTORY = 8,
					WON = 9,
					CONFIG_WR_W = 10,
					WAIT_WR_W = 11,
					CLEAR_M = 12,
					CONFIG_WR_C =  13,
					WAIT_WR_C = 14;

///////////////////////////////////////////

// Decodificador de proximo estado
always @(*)
begin
	next_state = state;
	case(state)
		IDLE:
		begin
			if(active == 1)
				next_state = RECEIVE;   // recebeu sinal para colocar uma peça; irá ler a matriz
			else
				next_state = IDLE;
		end
		//
		RECEIVE: next_state = CONFIG_RD;
		//
		CLEAR_M:
		begin
			if(h < 42)
				next_state = CONFIG_WR_C;   // ainda existem linhas a serem resetadas
			else
				next_state = IDLE;          // não existem mais linhas a serem resetadas
		end
		//
		CONFIG_RD: next_state = WAIT_RD;
		//
		WAIT_RD:
		begin
			if(ready == 1)
				next_state = CHECK;         // recebeu a data
			else
				next_state = WAIT_RD;       // ainda não recebeu a data
		end
		//
		CHECK:
		begin
			if(vetor[coluna_atual + k] != 00) // se não tiver espaço
			begin
				if(k > 0)
					next_state = CONFIG_RD;  // chegou o limite da matriz
				else
					next_state = GEN_RESP;
			end
			else // se tem espaço
			begin
				next_state = CONFIG_WR;
			end
		end
		//
		CONFIG_WR: next_state = WAIT_WR;
		//
		WAIT_WR:
		begin
			if(ready == 1)
				next_state = GEN_RESP;
			else
				next_state = WAIT_WR;
		end
		//
		WAIT_WR_C:
		begin
			if(ready == 1)
				next_state = CLEAR_M;
			else
				next_state = WAIT_WR_C;
		end
		//
		CONFIG_WR_C: next_state = WAIT_WR_C;
		//
		GEN_RESP: next_state = CHECK_VICTORY;
		//
		CHECK_VICTORY:
		begin
			if(player1_won == 1 || player2_won == 1)
				next_state = WON;
			else
				next_state = IDLE;
		end
		//
		WON:
		begin
			if(!reset) 
				next_state = CLEAR_M;
			else
			begin
				if(h < 42)
					next_state = CONFIG_WR_W;
				else
					next_state = WON;
			end
		end
		//
		CONFIG_WR_W: next_state = WAIT_WR_W;
		//
		WAIT_WR_W:
		begin
			if(ready == 1)
				next_state = WON;
			else
				next_state = WAIT_WR_W;
		end
	endcase
end

///////////////////////////////////////////

// Memoria
always@(posedge clk)
begin
	if (!reset)
	begin
		player <= 1;
		coluna_atual <= 0;
		state <= CLEAR_M;
		k <= 0;
		h <= 0;
		fix <= 0;
		player1_won <= 0;
		player2_won <= 0;
		vetor[0] <= 0;
		vetor[1] <= 0;
		vetor[2] <= 0;
		vetor[3] <= 0;
		vetor[4] <= 0;
		vetor[5] <= 0;
		vetor[6] <= 0;
		vetor[7] <= 0;
		vetor[8] <= 0;
		vetor[9] <= 0;
		vetor[10] <= 0;
		vetor[11] <= 0;
		vetor[12] <= 0;
		vetor[13] <= 0;
		vetor[14] <= 0;
		vetor[15] <= 0;
		vetor[16] <= 0;
		vetor[17] <= 0;
		vetor[18] <= 0;
		vetor[19] <= 0;
		vetor[20] <= 0;
		vetor[21] <= 0;
		vetor[22] <= 0;
		vetor[23] <= 0;
		vetor[24] <= 0;
		vetor[25] <= 0; 
		vetor[26] <= 0;
		vetor[27] <= 0;
		vetor[28] <= 0;
		vetor[29] <= 0;
		vetor[30] <= 0;
		vetor[31] <= 0;
		vetor[32] <= 0;
		vetor[33] <= 0;
		vetor[34] <= 0;
		vetor[35] <= 0;
		vetor[36] <= 0;
		vetor[37] <= 0;
		vetor[38] <= 0;
		vetor[39] <= 0; 
		vetor[40] <= 0; 
		vetor[41] <= 0;
	end
	else
	begin
		state <= next_state;
		player <= player;
		coluna_atual <= coluna_atual;
		player1_won <= player1_won;
		player2_won <= player2_won;

		fix <= fix;
				
		if(state == RECEIVE)
		begin
			coluna_atual <= coluna_in;
			player <= player_in;
			h <= 0;
			k <= 35;
		end
		else if(state == CONFIG_WR)
		begin
			vetor[coluna_atual + k] <= player;
			fix <= 1;
		end
		else if(state == GEN_RESP)
		begin
			player1_won <= ((vetor[0] == 2'b01 && vetor[1] == 2'b01 && vetor[2] == 2'b01 && vetor[3] == 2'b01) || // HORIZONTAL && termino linha 0
						(vetor[1] == 2'b01 && vetor[2] == 2'b01 && vetor[3] == 2'b01 && vetor[4] == 2'b01) ||
						(vetor[2] == 2'b01 && vetor[3] == 2'b01 && vetor[4] == 2'b01 && vetor[5] == 2'b01) ||
						(vetor[3] == 2'b01 && vetor[4] == 2'b01 && vetor[5] == 2'b01 && vetor[6] == 2'b01) || //termino linha 1
						(vetor[7] == 2'b01 && vetor[8] == 2'b01 && vetor[9] == 2'b01 && vetor[10] == 2'b01) ||
						(vetor[8] == 2'b01 && vetor[9] == 2'b01 && vetor[10] == 2'b01 && vetor[11] == 2'b01) || 
						(vetor[9] == 2'b01 && vetor[10] == 2'b01 && vetor[11] == 2'b01 && vetor[12] == 2'b01) ||
						(vetor[10] == 2'b01 && vetor[11] == 2'b01 && vetor[12] == 2'b01 && vetor[13] == 2'b01) || // termino linha 2
						(vetor[14] == 2'b01 && vetor[15] == 2'b01 && vetor[16] == 2'b01 && vetor[17] == 2'b01) ||   
						(vetor[15] == 2'b01 && vetor[16] == 2'b01 && vetor[17] == 2'b01 && vetor[18] == 2'b01) ||
						(vetor[16] == 2'b01 && vetor[17] == 2'b01 && vetor[18] == 2'b01 && vetor[19] == 2'b01) ||
						(vetor[17] == 2'b01 && vetor[18] == 2'b01 && vetor[19] == 2'b01 && vetor[20] == 2'b01) || //termino linha 3
						(vetor[21] == 2'b01 && vetor[22] == 2'b01 && vetor[23] == 2'b01 && vetor[24] == 2'b01) ||
						(vetor[22] == 2'b01 && vetor[23] == 2'b01 && vetor[24] == 2'b01 && vetor[25] == 2'b01) ||
						(vetor[23] == 2'b01 && vetor[24] == 2'b01 && vetor[25] == 2'b01 && vetor[26] == 2'b01) ||
						(vetor[24] == 2'b01 && vetor[25] == 2'b01 && vetor[26] == 2'b01 && vetor[27] == 2'b01) || //termino linha 4
						(vetor[28] == 2'b01 && vetor[29] == 2'b01 && vetor[30] == 2'b01 && vetor[31] == 2'b01) ||
						(vetor[29] == 2'b01 && vetor[30] == 2'b01 && vetor[31] == 2'b01 && vetor[32] == 2'b01) ||
						(vetor[30] == 2'b01 && vetor[31] == 2'b01 && vetor[32] == 2'b01 && vetor[33] == 2'b01) ||
						(vetor[31] == 2'b01 && vetor[32] == 2'b01 && vetor[33] == 2'b01 && vetor[34] == 2'b01) || // termino linha 5
						(vetor[35] == 2'b01 && vetor[36] == 2'b01 && vetor[37] == 2'b01 && vetor[38] == 2'b01) ||
						(vetor[36] == 2'b01 && vetor[37] == 2'b01 && vetor[38] == 2'b01 && vetor[39] == 2'b01) ||
						(vetor[37] == 2'b01 && vetor[38] == 2'b01 && vetor[39] == 2'b01 && vetor[40] == 2'b01) ||
						(vetor[38] == 2'b01 && vetor[39] == 2'b01 && vetor[40] == 2'b01 && vetor[41] == 2'b01) || // termino linha 5
						(vetor[0] == 2'b01 && vetor[7] == 2'b01 && vetor[14] == 2'b01 && vetor[21] == 2'b01)   || // VERTICAL && coluna 0
						(vetor[7] == 2'b01 && vetor[14] == 2'b01 && vetor[21] == 2'b01 && vetor[28] == 2'b01)  ||
						(vetor[14] == 2'b01 && vetor[21] == 2'b01 && vetor[28] == 2'b01 && vetor[35] == 2'b01) ||
						(vetor[1] == 2'b01 && vetor[8] == 2'b01 && vetor[15] == 2'b01 && vetor[22] == 2'b01)   || // coluna 1
						(vetor[8] == 2'b01 && vetor[15] == 2'b01 && vetor[22] == 2'b01 && vetor[29] == 2'b01)  || 
						(vetor[15] == 2'b01 && vetor[22] == 2'b01 && vetor[29] == 2'b01 && vetor[36] == 2'b01) || 
						(vetor[2] == 2'b01 && vetor[9] == 2'b01 && vetor[16] == 2'b01 && vetor[23] == 2'b01)   || // coluna 2
						(vetor[9] == 2'b01 && vetor[16] == 2'b01 && vetor[23] == 2'b01 && vetor[30] == 2'b01)  ||
						(vetor[16] == 2'b01 && vetor[23] == 2'b01 && vetor[30] == 2'b01 && vetor[37] == 2'b01) ||   
						(vetor[3] == 2'b01 && vetor[10] == 2'b01 && vetor[17] == 2'b01 && vetor[24] == 2'b01)  || // coluna 3
						(vetor[10] == 2'b01 && vetor[17] == 2'b01 && vetor[24] == 2'b01 && vetor[31] == 2'b01) || 
						(vetor[17] == 2'b01 && vetor[24] == 2'b01 && vetor[31] == 2'b01 && vetor[38] == 2'b01) ||
						(vetor[4] == 2'b01 && vetor[11] == 2'b01 && vetor[18] == 2'b01 && vetor[25] == 2'b01)  || // coluna 4
						(vetor[11] == 2'b01 && vetor[18] == 2'b01 && vetor[25] == 2'b01 && vetor[32] == 2'b01) ||
						(vetor[18] == 2'b01 && vetor[25] == 2'b01 && vetor[32] == 2'b01 && vetor[39] == 2'b01) ||
						(vetor[5] == 2'b01 && vetor[12] == 2'b01 && vetor[19] == 2'b01 && vetor[26] == 2'b01)  || // coluna 5
						(vetor[12] == 2'b01 && vetor[19] == 2'b01 && vetor[26] == 2'b01 && vetor[33] == 2'b01) ||
						(vetor[19] == 2'b01 && vetor[26] == 2'b01 && vetor[33] == 2'b01 && vetor[40] == 2'b01) || 
						(vetor[6] == 2'b01 && vetor[13] == 2'b01 && vetor[20] == 2'b01 && vetor[27] == 2'b01)  || // coluna 6
						(vetor[13] == 2'b01 && vetor[20] == 2'b01 && vetor[27] == 2'b01 && vetor[34] == 2'b01) ||
						(vetor[20] == 2'b01 && vetor[27] == 2'b01 && vetor[34] == 2'b01 && vetor[41] == 2'b01) || // termino coluna 6
						(vetor[21] == 2'b01 && vetor[15] == 2'b01 && vetor[9] == 2'b01 && vetor[3] == 2'b01)   || // diagonal ascendente 
						(vetor[28] == 2'b01 && vetor[22] == 2'b01 && vetor[16] == 2'b01 && vetor[10] == 2'b01) ||
						(vetor[22] == 2'b01 && vetor[16] == 2'b01 && vetor[10] == 2'b01 && vetor[4] == 2'b01)  || 
						(vetor[35] == 2'b01 && vetor[29] == 2'b01 && vetor[23] == 2'b01 && vetor[17] == 2'b01) ||
						(vetor[29] == 2'b01 && vetor[23] == 2'b01 && vetor[17] == 2'b01 && vetor[11] == 2'b01) ||
						(vetor[23] == 2'b01 && vetor[17] == 2'b01 && vetor[11] == 2'b01 && vetor[5] == 2'b01)  || 
						(vetor[36] == 2'b01 && vetor[30] == 2'b01 && vetor[24] == 2'b01 && vetor[18] == 2'b01) ||
						(vetor[30] == 2'b01 && vetor[24] == 2'b01 && vetor[18] == 2'b01 && vetor[12] == 2'b01) ||
						(vetor[24] == 2'b01 && vetor[18] == 2'b01 && vetor[12] == 2'b01 && vetor[6] == 2'b01)  || 
						(vetor[37] == 2'b01 && vetor[31] == 2'b01 && vetor[25] == 2'b01 && vetor[19] == 2'b01) ||
						(vetor[31] == 2'b01 && vetor[25] == 2'b01 && vetor[19] == 2'b01 && vetor[13] == 2'b01) || 
						(vetor[38] == 2'b01 && vetor[32] == 2'b01 && vetor[26] == 2'b01 && vetor[20] == 2'b01) || // fim diagonal ascendente
						(vetor[14] == 2'b01 && vetor[22] == 2'b01 && vetor[30] == 2'b01 && vetor[38] == 2'b01) || // diagonal descendente
						(vetor[7] == 2'b01 && vetor[15] == 2'b01 && vetor[23] == 2'b01 && vetor[31] == 2'b01)  || 
						(vetor[15] == 2'b01 && vetor[23] == 2'b01 && vetor[31] == 2'b01 && vetor[39] == 2'b01) ||
						(vetor[0] == 2'b01 && vetor[8] == 2'b01 && vetor[16] == 2'b01 && vetor[24] == 2'b01)   || 
						(vetor[8] == 2'b01 && vetor[16] == 2'b01 && vetor[24] == 2'b01 && vetor[32] == 2'b01)  ||
						(vetor[16] == 2'b01 && vetor[24] == 2'b01 && vetor[32] == 2'b01 && vetor[40] == 2'b01) || 
						(vetor[1] == 2'b01 && vetor[9] == 2'b01 && vetor[17] == 2'b01 && vetor[25] == 2'b01)   ||
						(vetor[9] == 2'b01 && vetor[17] == 2'b01 && vetor[25] == 2'b01 && vetor[33] == 2'b01)  ||
						(vetor[17] == 2'b01 && vetor[25] == 2'b01 && vetor[33] == 2'b01 && vetor[41] == 2'b01) ||   
						(vetor[2] == 2'b01 && vetor[10] == 2'b01 && vetor[18] == 2'b01 && vetor[26] == 2'b01)  ||
						(vetor[10] == 2'b01 && vetor[18] == 2'b01 && vetor[26] == 2'b01 && vetor[34] == 2'b01) || 
						(vetor[3] == 2'b01 && vetor[11] == 2'b01 && vetor[19] == 2'b01 && vetor[27] == 2'b01) //final diagonal descendente
						);
					
		
		player2_won <= ((vetor[0] == 2'b10 && vetor[1] == 2'b10 && vetor[2] == 2'b10 && vetor[3] == 2'b10) || // HORIZONTAL && termino linha 0
						(vetor[1] == 2'b10 && vetor[2] == 2'b10 && vetor[3] == 2'b10 && vetor[4] == 2'b10) ||
						(vetor[2] == 2'b10 && vetor[3] == 2'b10 && vetor[4] == 2'b10 && vetor[5] == 2'b10) ||
						(vetor[3] == 2'b10 && vetor[4] == 2'b10 && vetor[5] == 2'b10 && vetor[6] == 2'b10) || //termino linha 1
						(vetor[7] == 2'b10 && vetor[8] == 2'b10 && vetor[9] == 2'b10 && vetor[10] == 2'b10) ||
						(vetor[8] == 2'b10 && vetor[9] == 2'b10 && vetor[10] == 2'b10 && vetor[11] == 2'b10) || 
						(vetor[9] == 2'b10 && vetor[10] == 2'b10 && vetor[11] == 2'b10 && vetor[12] == 2'b10) ||
						(vetor[10] == 2'b10 && vetor[11] == 2'b10 && vetor[12] == 2'b10 && vetor[13] == 2'b10) || // termino linha 2
						(vetor[14] == 2'b10 && vetor[15] == 2'b10 && vetor[16] == 2'b10 && vetor[17] == 2'b10) ||   
						(vetor[15] == 2'b10 && vetor[16] == 2'b10 && vetor[17] == 2'b10 && vetor[18] == 2'b10) ||
						(vetor[16] == 2'b10 && vetor[17] == 2'b10 && vetor[18] == 2'b10 && vetor[19] == 2'b10) ||
						(vetor[17] == 2'b10 && vetor[18] == 2'b10 && vetor[19] == 2'b10 && vetor[20] == 2'b10) || //termino linha 3
						(vetor[21] == 2'b10 && vetor[22] == 2'b10 && vetor[23] == 2'b10 && vetor[24] == 2'b10) ||
						(vetor[22] == 2'b10 && vetor[23] == 2'b10 && vetor[24] == 2'b10 && vetor[25] == 2'b10) ||
						(vetor[23] == 2'b10 && vetor[24] == 2'b10 && vetor[25] == 2'b10 && vetor[26] == 2'b10) ||
						(vetor[24] == 2'b10 && vetor[25] == 2'b10 && vetor[26] == 2'b10 && vetor[27] == 2'b10) || //termino linha 4
						(vetor[28] == 2'b10 && vetor[29] == 2'b10 && vetor[30] == 2'b10 && vetor[31] == 2'b10) ||
						(vetor[29] == 2'b10 && vetor[30] == 2'b10 && vetor[31] == 2'b10 && vetor[32] == 2'b10) ||
						(vetor[30] == 2'b10 && vetor[31] == 2'b10 && vetor[32] == 2'b10 && vetor[33] == 2'b10) ||
						(vetor[31] == 2'b10 && vetor[32] == 2'b10 && vetor[33] == 2'b10 && vetor[34] == 2'b10) || // termino linha 5
						(vetor[35] == 2'b10 && vetor[36] == 2'b10 && vetor[37] == 2'b10 && vetor[38] == 2'b10) ||
						(vetor[36] == 2'b10 && vetor[37] == 2'b10 && vetor[38] == 2'b10 && vetor[39] == 2'b10) ||
						(vetor[37] == 2'b10 && vetor[38] == 2'b10 && vetor[39] == 2'b10 && vetor[40] == 2'b10) ||
						(vetor[38] == 2'b10 && vetor[39] == 2'b10 && vetor[40] == 2'b10 && vetor[41] == 2'b10) || // termino linha 5
						(vetor[0] == 2'b10 && vetor[7] == 2'b10 && vetor[14] == 2'b10 && vetor[21] == 2'b10)   || // VERTICAL && coluna 0
						(vetor[7] == 2'b10 && vetor[14] == 2'b10 && vetor[21] == 2'b10 && vetor[28] == 2'b10)  ||
						(vetor[14] == 2'b10 && vetor[21] == 2'b10 && vetor[28] == 2'b10 && vetor[35] == 2'b10) ||
						(vetor[1] == 2'b10 && vetor[8] == 2'b10 && vetor[15] == 2'b10 && vetor[22] == 2'b10)   || // coluna 1
						(vetor[8] == 2'b10 && vetor[15] == 2'b10 && vetor[22] == 2'b10 && vetor[29] == 2'b10)  || 
						(vetor[15] == 2'b10 && vetor[22] == 2'b10 && vetor[29] == 2'b10 && vetor[36] == 2'b10) || 
						(vetor[2] == 2'b10 && vetor[9] == 2'b10 && vetor[16] == 2'b10 && vetor[23] == 2'b10)   || // coluna 2
						(vetor[9] == 2'b10 && vetor[16] == 2'b10 && vetor[23] == 2'b10 && vetor[30] == 2'b10)  ||
						(vetor[16] == 2'b10 && vetor[23] == 2'b10 && vetor[30] == 2'b10 && vetor[37] == 2'b10) ||   
						(vetor[3] == 2'b10 && vetor[10] == 2'b10 && vetor[17] == 2'b10 && vetor[24] == 2'b10)  || // coluna 3
						(vetor[10] == 2'b10 && vetor[17] == 2'b10 && vetor[24] == 2'b10 && vetor[31] == 2'b10) || 
						(vetor[17] == 2'b10 && vetor[24] == 2'b10 && vetor[31] == 2'b10 && vetor[38] == 2'b10) ||
						(vetor[4] == 2'b10 && vetor[11] == 2'b10 && vetor[18] == 2'b10 && vetor[25] == 2'b10)  || // coluna 4
						(vetor[11] == 2'b10 && vetor[18] == 2'b10 && vetor[25] == 2'b10 && vetor[32] == 2'b10) ||
						(vetor[18] == 2'b10 && vetor[25] == 2'b10 && vetor[32] == 2'b10 && vetor[39] == 2'b10) ||
						(vetor[5] == 2'b10 && vetor[12] == 2'b10 && vetor[19] == 2'b10 && vetor[26] == 2'b10)  || // coluna 5
						(vetor[12] == 2'b10 && vetor[19] == 2'b10 && vetor[26] == 2'b10 && vetor[33] == 2'b10) ||
						(vetor[19] == 2'b10 && vetor[26] == 2'b10 && vetor[33] == 2'b10 && vetor[40] == 2'b10) || 
						(vetor[6] == 2'b10 && vetor[13] == 2'b10 && vetor[20] == 2'b10 && vetor[27] == 2'b10)  || // coluna 6
						(vetor[13] == 2'b10 && vetor[20] == 2'b10 && vetor[27] == 2'b10 && vetor[34] == 2'b10) ||
						(vetor[20] == 2'b10 && vetor[27] == 2'b10 && vetor[34] == 2'b10 && vetor[41] == 2'b10) || // termino coluna 6
						(vetor[21] == 2'b10 && vetor[15] == 2'b10 && vetor[9] == 2'b10 && vetor[3] == 2'b10)   || // diagonal ascendente 
						(vetor[28] == 2'b10 && vetor[22] == 2'b10 && vetor[16] == 2'b10 && vetor[10] == 2'b10) ||
						(vetor[22] == 2'b10 && vetor[16] == 2'b10 && vetor[10] == 2'b10 && vetor[4] == 2'b10)  || 
						(vetor[35] == 2'b10 && vetor[29] == 2'b10 && vetor[23] == 2'b10 && vetor[17] == 2'b10) ||
						(vetor[29] == 2'b10 && vetor[23] == 2'b10 && vetor[17] == 2'b10 && vetor[11] == 2'b10) ||
						(vetor[23] == 2'b10 && vetor[17] == 2'b10 && vetor[11] == 2'b10 && vetor[5] == 2'b10)  || 
						(vetor[36] == 2'b10 && vetor[30] == 2'b10 && vetor[24] == 2'b10 && vetor[18] == 2'b10) ||
						(vetor[30] == 2'b10 && vetor[24] == 2'b10 && vetor[18] == 2'b10 && vetor[12] == 2'b10) ||
						(vetor[24] == 2'b10 && vetor[18] == 2'b10 && vetor[12] == 2'b10 && vetor[6] == 2'b10)  || 
						(vetor[37] == 2'b10 && vetor[31] == 2'b10 && vetor[25] == 2'b10 && vetor[19] == 2'b10) ||
						(vetor[31] == 2'b10 && vetor[25] == 2'b10 && vetor[19] == 2'b10 && vetor[13] == 2'b10) || 
						(vetor[38] == 2'b10 && vetor[32] == 2'b10 && vetor[26] == 2'b10 && vetor[20] == 2'b10) || // fim diagonal ascendente
						(vetor[14] == 2'b10 && vetor[22] == 2'b10 && vetor[30] == 2'b10 && vetor[38] == 2'b10) || // diagonal descendente
						(vetor[7] == 2'b10 && vetor[15] == 2'b10 && vetor[23] == 2'b10 && vetor[31] == 2'b10)  || 
						(vetor[15] == 2'b10 && vetor[23] == 2'b10 && vetor[31] == 2'b10 && vetor[39] == 2'b10) ||
						(vetor[0] == 2'b10 && vetor[8] == 2'b10 && vetor[16] == 2'b10 && vetor[24] == 2'b10)   || 
						(vetor[8] == 2'b10 && vetor[16] == 2'b10 && vetor[24] == 2'b10 && vetor[32] == 2'b10)  ||
						(vetor[16] == 2'b10 && vetor[24] == 2'b10 && vetor[32] == 2'b10 && vetor[40] == 2'b10) || 
						(vetor[1] == 2'b10 && vetor[9] == 2'b10 && vetor[17] == 2'b10 && vetor[25] == 2'b10)   ||
						(vetor[9] == 2'b10 && vetor[17] == 2'b10 && vetor[25] == 2'b10 && vetor[33] == 2'b10)  ||
						(vetor[17] == 2'b10 && vetor[25] == 2'b10 && vetor[33] == 2'b10 && vetor[41] == 2'b10) ||   
						(vetor[2] == 2'b10 && vetor[10] == 2'b10 && vetor[18] == 2'b10 && vetor[26] == 2'b10)  ||
						(vetor[10] == 2'b10 && vetor[18] == 2'b10 && vetor[26] == 2'b10 && vetor[34] == 2'b10) || 
						(vetor[3] == 2'b10 && vetor[11] == 2'b10 && vetor[19] == 2'b10 && vetor[27] == 2'b10)     //final diagonal descendente
						);
		end
		else if(state == IDLE)
		begin
			k <= 35;
			fix <= 0;
		end
		//
		else if(state == WAIT_RD)
		begin 
			if(ready == 1) //confirmar se o bit mais significativo influencia
			begin
				vetor[k] <= {data_in[1], data_in[0]};
				vetor[k+1] <= {data_in[3], data_in[2]};
				vetor[k+2] <= {data_in[5], data_in[4]};
				vetor[k+3] <= {data_in[7], data_in[6]};
				vetor[k+4] <= {data_in[9], data_in[8]};
				vetor[k+5] <= {data_in[11], data_in[10]};
				vetor[k+6] <= {data_in[13], data_in[12]};                
			end
		end
		//
		else if(state == CHECK)
		begin
			if(k > 0 && vetor[coluna_atual + k] != 00) // se ainda não é a ultima linha
				k <= k - 7;
		end
		//
		else if(state == CLEAR_M)
		begin
			vetor[h] <= 0;
			if(h < 42)
				h <= h + 1;
		end
		else if(state == WON)
		begin
			if(!reset)
				h <= 0;
			else if(h < 42)
				h <= h + 1;
			else
				h <= h;
		end
		else if(state == CONFIG_WR_W)
		begin
			h <= h;
		end
		else if(state == WAIT_WR_W)
		begin
			h <= h;
		end
		else if(state == CONFIG_WR_C)
		begin
			h <= h;
		end
		else if(state == WAIT_WR_C)
		begin
			h <= h;
		end
		else
		begin
			h <= h;
			k <= k;     
			vetor[0] <= vetor[0];
			vetor[1] <= vetor[1];
			vetor[2] <= vetor[2];
			vetor[3] <= vetor[3];
			vetor[4] <= vetor[4];
			vetor[5] <= vetor[5];
			vetor[6] <= vetor[6];
			vetor[7] <= vetor[7];
			vetor[8] <= vetor[8];
			vetor[9] <= vetor[9];
			vetor[10] <= vetor[10];
			vetor[11] <= vetor[11];
			vetor[12] <= vetor[12];
			vetor[13] <= vetor[13];
			vetor[14] <= vetor[14];
			vetor[15] <= vetor[15]; 
			vetor[16] <= vetor[16]; 
			vetor[17] <= vetor[17]; 
			vetor[18] <= vetor[18];
			vetor[19] <= vetor[19];
			vetor[20] <= vetor[20];
			vetor[21] <= vetor[21];
			vetor[22] <= vetor[22];
			vetor[23] <= vetor[23];
			vetor[24] <= vetor[24];
			vetor[25] <= vetor[25]; 
			vetor[26] <= vetor[26]; 
			vetor[27] <= vetor[27]; 
			vetor[28] <= vetor[28];
			vetor[29] <= vetor[29];
			vetor[30] <= vetor[30];
			vetor[31] <= vetor[31];
			vetor[32] <= vetor[32];
			vetor[33] <= vetor[33];
			vetor[34] <= vetor[34];
			vetor[35] <= vetor[35];
			vetor[36] <= vetor[36];
			vetor[37] <= vetor[37];
			vetor[38] <= vetor[38];
			vetor[39] <= vetor[39]; 
			vetor[40] <= vetor[40]; 
			vetor[41] <= vetor[41]; 
		end
	end
end 

///////////////////////////////////////////

// Decodificador de saída
always@(*)
begin
	case(state)
		IDLE:
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		RECEIVE: 
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		CONFIG_RD:
		begin
			q = 0;
			response = 0;
			addr = k;
			rden = 0;
			wren = 0;
		end
		//      
		WAIT_RD:
		begin
			q = 0;
			response = 0;
			addr = k;   
			rden = 1;
			wren = 0;
		end
		//      
		CHECK: 
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//           
		CONFIG_WR:
		begin 
			q = player; 
			response = 0;
			addr = coluna_atual + k;
			rden = 0;
			wren = 0;
		end
		//      
		WAIT_WR:
		begin
			q = player;
			response = 0;
			addr = coluna_atual + k;
			rden = 0;
			wren = 1;
		end
		//      
		GEN_RESP:
		begin
			q = 0;
			//if(vetor[coluna_atual + k] == 0) // da pra por
			if(fix == 1)
				response = 2; // conseguiu colocar a peça
			else
				response = 1; // não conseguiu colocar a peça
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		CHECK_VICTORY:
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		WON:
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		CONFIG_WR_W:
		begin
			q = player;
			response = 0;
			addr = h - 1;
			rden = 0;
			wren = 0;
		end
		//      
		WAIT_WR_W:
		begin
			q = player;
			response = 0;
			addr = h - 1;
			rden = 0;
			wren = 1;
		end
		//      
		CLEAR_M:
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
		//      
		CONFIG_WR_C:
		begin
			q = 0;
			response = 0;
			addr = h - 1;
			rden = 0;
			wren = 0;
		end
		//      
		WAIT_WR_C:
		begin
			q = 0;
			response = 0;
			addr = h - 1;
			rden = 0;
			wren = 1;
		end
		// 
		default:
		begin
			q = 0;
			response = 0;
			addr = 0;
			rden = 0;
			wren = 0;
		end
	endcase     
end
endmodule