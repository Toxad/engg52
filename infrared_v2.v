module infrared_v2( E,
					clk,
					rst,
					cdleft,
					cdright,
					cdsel,
					cdrst
				);

// inputs/outputs

input 				E;
input 				clk;
input 				rst;
output reg		 	cdleft, cdright, cdsel, cdrst;

// estados

reg [2:0]			state, next_state;
parameter 			IDLE 		= 0,
					PASS_ZERO 	= 1,
					PASS_HIGH	= 2,
					COUNT_HIGH	= 3,
					STORE		= 4,
					SEND		= 5;

// outros

reg [31:0]			msg;
reg [5:0]			i;
integer				count;
parameter			MIN_E 		= 10,
					MID_E 		= 38,
					MAX_E 		= 70,

					SEND_LEFT	= 16'b1110101100010100,
					SEND_RIGHT	= 16'b1110011100011000,
					SEND_SEL		= 16'b1110100000010111,
					SEND_RST		= 16'b1110110100010010;

//////////////////////////////////

always @(*)
begin
	case(state)
		IDLE:
		begin
			if(E == 1)
				next_state = IDLE;
			else
				next_state = PASS_ZERO;
		end
		PASS_ZERO:
		begin
			if(i == 0 && E == 1)
				next_state = PASS_HIGH;
			else if(i > 0 && E == 1)
				next_state = COUNT_HIGH;
			else
				next_state = PASS_ZERO;
		end
		PASS_HIGH:
		begin
			if(E == 1)
				next_state = PASS_HIGH;
			else
				next_state = PASS_ZERO;
		end
		COUNT_HIGH:
		begin
			if(i > 32 || count > 500)
				next_state = SEND;
			else if(E == 1)
				next_state = COUNT_HIGH;
			else
				next_state = STORE;
		end
		STORE:
			next_state = IDLE;
		SEND:
			next_state = IDLE;
		default:
			next_state = IDLE;
	endcase
end

//////////////////////////////////

always @(posedge clk)
begin
	if(!rst)
	begin
		state = IDLE;
		count = 0;
		i = 0;
		msg[31:0] = 0;
	end
	else
	begin
		msg = msg;
		i = i;
		count = count;
		state = next_state;
		case(state)
			IDLE:
			begin
				count = 0;
			end
			PASS_ZERO:
			begin
				count = 0;
			end
			PASS_HIGH:
			begin
				i = 1;
			end
			COUNT_HIGH:
			begin
				count = count + 1;
			end
			STORE:
			begin
				if(count >= MIN_E && count < MID_E)
				begin
					msg[i-1] = 0;
					i = i + 1;
				end
				else if(count >= MID_E && count <= MAX_E)
				begin
					msg[i-1] = 1;
					i = i + 1;
				end
			end
			SEND:
			begin
				i = 0;
			end
		endcase
	end
end

//////////////////////////////////

always @(*)
begin
	case(state)
		SEND:
		begin
			if(msg[31:16] == SEND_LEFT)
			begin
				cdleft 	= 0;
				cdright	= 1;
				cdsel	= 1;
				cdrst	= 1;
			end
			else if(msg[31:16] == SEND_RIGHT)
			begin
				cdleft 	= 1;
				cdright	= 0;
				cdsel	= 1;
				cdrst	= 1;
			end
			else if(msg[31:16] == SEND_SEL)
			begin
				cdleft 	= 1;
				cdright	= 1;
				cdsel	= 0;
				cdrst	= 1;
			end
			else if(msg[31:16] == SEND_RST)
			begin
				cdleft 	= 1;
				cdright	= 1;
				cdsel	= 1;
				cdrst	= 0;
			end
			else
			begin
				cdleft 	= 1;
				cdright	= 1;
				cdsel	= 1;
				cdrst	= 1;
			end
		end
		default:
		begin
			cdleft 	= 1;
			cdright	= 1;
			cdsel	= 1;
			cdrst	= 1;
		end
	endcase
end

endmodule