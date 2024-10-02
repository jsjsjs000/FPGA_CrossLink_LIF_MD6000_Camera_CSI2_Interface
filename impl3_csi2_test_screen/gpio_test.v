module leds(
	input CLKI,
	output CLKOS,
	input Reset_n,
	output reg LED1,
	output reg LED2
);

	reg [27:0] counter = 28'd0;
	
	always @(posedge CLKOS, negedge Reset_n) begin
		if (!Reset_n) begin
			counter <= 28'd0;
			LED1 <= 1'b0;
			LED2 <= 1'b1;
		end
		else begin
			if (counter == 78_000_000 / 2 - 1) begin
				LED1 <= !LED1;
				LED2 <= !LED2;
				counter <= 28'd0;
			end
			else begin
				counter <= counter + 1'b1;
			end
		end
	end

	int_pll int_pll_inst(
		.CLKI(CLKI),
		.CLKOS(CLKOS),
		.RST(~Reset_n)
	);

endmodule

// Generate 1Hz on LED
