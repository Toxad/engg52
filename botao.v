module botao(       reset,
                    active,
                    coluna_out,
                    player_out,
                    coluna_signal,
                    player_signal,
                    clk,
                    mvE, // esquerda
             		  mvD, //direita
                    sel,
                    response_ctl,
                    response_vga
            );
 
input               reset, clk, mvE, mvD, sel, response_vga;
input               [1:0]           response_ctl;
output reg          active, player_signal;
output reg          [2:0] coluna_out;
output reg          [1:0] player_out, coluna_signal;//modificado
 
//////////////////////////////////////////////////////// 
 
parameter           idle         = 0,
                    select       = 1,
                   // check = 2,
                    change_p     = 3,
                    moveD        = 4,
                    waiting      = 5,
                    wait_vga_col = 6,
                    wait_vga_p   = 7,
  						      moveE        = 8;
						  
						  
reg					  guarda;
						  
reg [2:0]           coluna_atual;
reg [3:0]           state, next_state;
reg [1:0]           player;
 
////////////////////////////////////////////////////////
 
// decodificador de proximo estado ,modificado
always @ (*)
begin
    case(state)
        idle:
        begin
          if (mvD == 0)
              next_state = moveD;
				  
          else if (mvE == 0)
          		next_state = moveE;
					
          else if (sel == 0)
              next_state = select;
          else
              next_state = idle;
        end
        //
        moveD: next_state = wait_vga_col;
        //
        moveE: next_state = wait_vga_col;
        //      
        select: next_state = waiting;
        //
        waiting:
        begin
            if (response_ctl == 1)
                    next_state = idle;
            else if (response_ctl == 2)
                    next_state = change_p;
            else
                next_state = waiting;
        end
        //
        change_p: next_state = wait_vga_p;
        //
        wait_vga_p:
        begin
            if(response_vga == 1)
                next_state = idle;
            else
                next_state = wait_vga_p;
        end
        //
        wait_vga_col:
        begin
            if(response_vga == 1)
                next_state = idle;
            else
                next_state = wait_vga_col;
        end
        //
        default: next_state = idle;
    endcase
end
 
////////////////////////////////////////////////////////
 
// memoria, modificado
always @ (posedge clk)
begin
    if (!reset)
    begin
        state <= idle;
        player <= 1;
        coluna_atual <= 0;
    end
    else
    begin
			guarda <= guarda;
        state <= next_state;
        if(state == change_p)
        begin
            coluna_atual <= coluna_atual;
            if(player == 1)
                player <= 2;
            else if(player == 2)
                player <= 1;
        end
      	//move direita
      	else if(state == moveD)
        begin
	    guarda <= 1;
            player <= player;
            if(coluna_atual < 6)
                coluna_atual <= coluna_atual + 1;
            else
                coluna_atual <= 0;
        end
      	//move esquerda
      	else if(state == moveE)
        begin
	    guarda <= 0;
            player <= player;
          	if(coluna_atual > 0)
                coluna_atual <= coluna_atual - 1;
            else
                coluna_atual <= 6;
        end
    end
end
 
////////////////////////////////////////////////////////
 
// decodificador de saida modificado
always @ (*)
begin
    case(state)
        select:
        begin
            active = 0;
            coluna_signal = 2'b00;
            player_signal = 0;
            coluna_out = coluna_atual;//<-- se e direita ou esquerda?
            player_out = player;
        end
        //
        waiting:
        begin
            active = 1;
            coluna_out = coluna_atual;
            player_out = player;
            coluna_signal = 2'b00;
            player_signal = 0;
        end
        //
        wait_vga_p:
        begin
            active = 0;
            coluna_out = 0;
            player_out = 0;
            coluna_signal = 2'b00;
            player_signal = 1;
        end
        //
        wait_vga_col: 
        begin
            active = 0;
            coluna_out = 0;
            player_out = 0;
            player_signal = 0;
				if (guarda == 1)
					coluna_signal = 2'b01;
				else if (guarda == 0)
					coluna_signal = 2'b10;
					else
							coluna_signal = 0;
        end
        //
        default:
        begin
            active = 0;
            coluna_out = 0;
            player_out = 0;
            coluna_signal = 2'b00;
            player_signal = 0;
        end
    endcase
end
 
endmodule