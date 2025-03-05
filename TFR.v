module TFR 
(
	TwAddr,
	tw
);	

	input [3:0] TwAddr;
	output [15:0] tw;
	
	wire [15:0] lut[15:0];
	assign tw=lut[TwAddr];
	// LUT data for both audio and video register
	assign lut[0]  = 16'h7f00,
			 lut[1]  = 16'h7d18,
			 lut[2]  = 16'h7630,
			 lut[3]  = 16'h6a47,
			 lut[4]  = 16'h5a5a,
			 lut[5]  = 16'h476a,
			 lut[6]  = 16'h3076,
			 lut[7]  = 16'h187d,
			 lut[8]  = 16'h007f,
			 lut[9]  = 16'he87d,
			 lut[10] = 16'he076,
			 lut[11] = 16'hb96a,
			 lut[12] = 16'ha65a,
			 lut[13] = 16'h9647,
			 lut[14] = 16'h8a30,
			 lut[15] = 16'h8318; 	 
endmodule				
