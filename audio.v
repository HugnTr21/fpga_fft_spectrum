module audio 
(
	aud_xclk	, // clock 12. MHz
	bclk 		, // bit stream clock
	adclrck	, // left right clock ADC
	adcdat	, // data stream ADC
	i2c_sclk		, // serial clock I2C
	i2c_sdat		, // serail data I2C
	swt		,
	clk		, // clock 50 MHz
	parallel
);   

	// input and output 
	input adcdat;
	input swt;
	input clk;
	input bclk;
	input adclrck;
	
	inout i2c_sdat;

	output aud_xclk;
	output i2c_sclk;
	output[7:0] parallel;

	/////////////////////////////////////////
	////        internal signals         ////
	/////////////////////////////////////////
	reg ctrl_clk;
	reg [15:0] clk_div;  // clock divider
	 
	wire[16:0] parallel_lf;
	wire[16:0] parallel_rt;
	
	I2C_programmer u1
	(
		.RESET(swt),			//  clock enable 
		.clk(clk),			//  50 Mhz clk from DE1-SoC
		.I2C_SCLK(i2c_sclk),		// I2C clock 40K
		.I2C_SDATA(i2c_sdat)		// bi directional serial data 
	);
		
	S2P u2 
	(
		.serial_adc(adcdat),		// 32 bit serial in data
		.PADCL(parallel_lf),
		.PADCR(parallel_rt), 
		.adc_lr(adclrck),
		.clk(bclk),				// 50 KHz clock
		.enable(swt)			// master reset
	);
	


	
	//////////////////////////////////////////////////////////////
	////// I2C clock (50 Mhz)used for DE1-SoC video in chip //////
	//////////////////////////////////////////////////////////////
	parameter clk_freq = 50000000;  // 50 Mhz
	parameter xclk_freq = 24576000;  // 12.288 Mhz
	always @ (posedge clk or negedge swt)
	begin
		if (!swt)
			begin
				clk_div <= 0;
				ctrl_clk <= 0;
			end
		else
			begin
				if (clk_div <  (clk_freq/xclk_freq) )  // keeps dividing until reaches desired frequency
					clk_div <= clk_div + 1;
				else
					begin 
						clk_div <= 0;
						ctrl_clk <= ~ctrl_clk;
					end
			end
	end
	
	
	assign parallel = (adclrck)? parallel_lf[15:8] : parallel_rt[15:8] ;
	assign aud_xclk = ctrl_clk; 
	
endmodule