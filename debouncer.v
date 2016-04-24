module debouncer (clk, reset, botao_in, botao_out);

input clk, reset, botao_in;
output botao_out;

integer contador;

always @(posedge clk)
begin
	if (!reset)
		contador <= 0;
	else
	begin
		if (botao_in)
			contador <= 0;
		else
		begin
			contador <= contador + 1;
			if (contador > 20_000_000)
				contador <= 0;
		end
	end
end

assign botao_out = (contador == 3_000)?0:1;

endmodule