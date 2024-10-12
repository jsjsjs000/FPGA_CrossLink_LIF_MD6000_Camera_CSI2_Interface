module image_generator ( 
                    reset_i,
					byte_clk_i,
					line_number_i,
                    hori_pixel_count_i,
					pixel_red_o,
					pixel_green_red_o,
					pixel_green_blue_o,
					pixel_blue_o
					);
					
					
	input reset_i;
	input byte_clk_i;
	input [11:0]line_number_i;
    input [11:0]hori_pixel_count_i;	
	
	output reg [9:0]pixel_red_o;
	output reg [9:0]pixel_green_red_o;
	output reg [9:0]pixel_green_blue_o;
	output reg [9:0]pixel_blue_o;
	
	reg [5:0]FrameCnt;
	reg FrameCntIncrComplete;
	
	reg [2:0]image_pattern;
	
	initial begin
		image_pattern <= 0;
		FrameCnt <= 6'd0;
		FrameCntIncrComplete <= 0;
	end
	
	always @(posedge byte_clk_i) begin
		if(~reset_i) begin
			image_pattern <= 3'd0;
			FrameCnt <= 6'd0;
			FrameCntIncrComplete <= 0;
		end
		else begin
			if(line_number_i == 1) begin
				if(FrameCntIncrComplete == 0) begin
					FrameCntIncrComplete <= 1;
				    FrameCnt <= FrameCnt + 1;
				    if(FrameCnt == 42) begin	           //change the image every 42 frames				    
					    if(image_pattern == 3) begin
						    image_pattern <= 0;
					    end
                        else begin
                            image_pattern <= image_pattern + 1;
                        end							
					    FrameCnt <= 0;
				    end
				end
			end
			else begin
				FrameCntIncrComplete <= 0;
			end
			
			//Image 0, horizontal lines of red blue green and white/yellow
			if(image_pattern == 0) begin  // height 480 (4 bars: 0, 120, 240, 360, 480)
				if((line_number_i <= 480) && (line_number_i >= 360)) begin
					pixel_red_o <=        10'b1111111111;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b0000000000;
				end
				else if((line_number_i < 360) && (line_number_i >= 240)) begin
					pixel_red_o <=        10'b0000000000;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b1111111111;
				end
				else if((line_number_i < 240) && (line_number_i >= 120)) begin
					pixel_red_o <=        10'b0000000000;   
	                pixel_green_red_o <=  10'b1111111111;    
	                pixel_green_blue_o <= 10'b1111111111;    
	                pixel_blue_o <=       10'b0000000000;
				end
				else begin
					pixel_red_o <=        10'b1111111111;   
	                pixel_green_red_o <=  10'b1111111111;    
	                pixel_green_blue_o <= 10'b1111111111;    
	                pixel_blue_o <=       10'b1000000000;
				end					
			end
			//Image 1, vertical lines of red blue green and white/yellow
			else if(image_pattern == 1) begin  // width 640 (RAW10 - 4 pixels = 5 bytes) - 640 * 5 / 4 = 800 / 2 = 400 (4 bars: 0, 100, 200, 300, 400)
				if((hori_pixel_count_i <= 400) && (hori_pixel_count_i >= 300)) begin
					pixel_red_o <=        10'b1111111111;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b0000000000;
				end
				else if((hori_pixel_count_i < 300) && (hori_pixel_count_i >= 200)) begin
					pixel_red_o <=        10'b0000000000;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b1111111111;
				end
				else if((hori_pixel_count_i < 200) && (hori_pixel_count_i >= 100)) begin
					pixel_red_o <=        10'b0000000000;   
	                pixel_green_red_o <=  10'b1111111111;    
	                pixel_green_blue_o <= 10'b1111111111;    
	                pixel_blue_o <=       10'b0000000000;
				end
				else begin
					pixel_red_o <=        10'b1111111111;   
	                pixel_green_red_o <=  10'b1111111111;    
	                pixel_green_blue_o <= 10'b1111111111;    
	                pixel_blue_o <=       10'b1000000000;
				end
			end
			//image 2 full red screen
			else if(image_pattern == 2) begin
					pixel_red_o <=        10'b1111111111;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b0000000000;
			end
			//image 3 full blue screen
			else if(image_pattern == 3) begin
					pixel_red_o <=        10'b0000000000;   
	                pixel_green_red_o <=  10'b0000000000;    
	                pixel_green_blue_o <= 10'b0000000000;    
	                pixel_blue_o <=       10'b1111111111;
			end
		end
	end	
	
endmodule