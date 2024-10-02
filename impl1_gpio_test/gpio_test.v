module gpio_test(led1, led2, reset);

input reset;
output reg led1;
output reg led2;

wire clk_osc;
reg [25:0] clk_f = 0;

defparam I1.HFCLKDIV = 1;
OSCI I1 (
	.HFOUTEN(1'b1),
	.HFCLKOUT(clk_osc),
	.LFCLKOUT(LFCLKOUT)
);

always @ (posedge clk_osc)
begin
	clk_f <= clk_f + 1'b1;	// Counter
end

always @ (posedge clk_f[20])
begin
	//if (reset == 0)
	//begin
		//led1 <= 1'b0;
		//led2 <= 1'b0;
	//end
	//else
	begin
		if ((clk_f & 26'b01000000000000000000000000) != 0)
		begin
			led1 <= 1'b0;
			led2 <= 1'b0;
		end
		else
		begin
			led1 <= 1'b1;
			led2 <= 1'b1;
		end
	end
end	

endmodule
