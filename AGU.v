module AGU 
(
	j,
	i,
	addr_1,
	addr_2,	
	TwAddr
);
			
	input[3:0]	j;
	input[2:0]	i;

	output [4:0]addr_1;
	output [4:0]addr_2;
	output [3:0]TwAddr;
	
	wire [4:0] mask;
	wire [3:0] pos;
	assign pos=i-1,
			 mask=({5{1'b1}}>>pos)<<pos,
			
		    addr_1 = ((j&mask)<<1)|(j&(~mask)),
		    addr_2 = addr_1|(1'b1<<pos),
			
		    TwAddr=j<<(5-i);
endmodule