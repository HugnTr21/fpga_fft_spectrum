module DO_AN_2
(
	bclk,  				// bit stream clock
	aud_xclk, 			// bit stream clock
	adclrck, 			// left right clock ADC
	adcdat, 				// data serial stream ADC
	i2c_sclk, 			// serial clock I2C
	i2c_sdat, 			// serail data I2C
	swt, 	
	row, 					// row ledmatrix
	column, 				// column ledmatrix
	clkin, 				// clock 50 MHz
	gpio
);

	//****************************  
	audio u0
	(
		.aud_xclk(aud_xclk),			
		.adclrck(adclrck),			
		.adcdat(adcdat),		
		.i2c_sclk(i2c_sclk),
		.i2c_sdat(i2c_sdat),
		.swt(swt),
		.bclk(bclk) ,
		.parallel(in),
		.clk(clkin)	
	);
	
	//**************Module Address Generation Unit**************  
	AGU u1 (
		.addr_1(addr_1),
		.addr_2(addr_2),
		.i(stage), 
		.j(cnt),
		.TwAddr(TwAddr)
	);	
	
	//**************Module Butterfly Unit**************
	BFU u2 (
		.tf(tw),
		.in1(bfin1),
		.in2(bfin2),
		.out1(bfout1),
		.out2(bfout2)
	);	
	
	//**************Module Twiddle factor ROM**************
	TFR u3 (
		.TwAddr(TwAddr),
		.tw(tw) 
	);

	//**********parmeters**************
	parameter n=32;
	parameter nl2=5;
	parameter sts= 4;
	parameter clk_freq = 50000000;  
	parameter sclk_freq = 16000; 
	parameter mclk_freq = 100000;
	parameter ledclk_freq = 800;
  
	//**********inputs and outputs**************
	input adclrck;
	input adcdat;
	input swt;	
	inout i2c_sdat;
	input clkin;
	input bclk;
  
	output aud_xclk;
	output i2c_sclk;
	output [7:0] row, column;
	output[7:0] gpio;
  
	wire[7:0] in; 
	wire mclk, sclk, ledclk;
	
	//**********Clock divide**************  
	reg ctrl_sclk; 	// output 8000 clock
	reg ctrl_mclk;  	// output 500k clock
	reg ctrl_ledclk; 	// output 500 clock
	
	reg [15:0] sclk_div;		// sampling clock divider
	reg [15:0] mclk_div;		// math clock divider
	reg [15:0] ledclk_div;	// led clock divider
	
	//sclk
	always @ (posedge clkin or negedge swt)
	begin
		if (!swt)
			begin
				sclk_div <= 0;
				ctrl_sclk <= 0;
			end
		else
			begin
				if (sclk_div <  (clk_freq/sclk_freq) )  // keeps dividing until reaches desired frequency
					sclk_div <= sclk_div + 1;
				else
					begin 
						sclk_div <= 0;
						ctrl_sclk <= ~ctrl_sclk;
					end
			end
	end
	
	//mclk
	always @ (posedge clkin or negedge swt)
	begin
		if (!swt)
			begin
				mclk_div <= 0;
				ctrl_mclk <= 0;
			end
		else
			begin
				if (mclk_div <  (clk_freq/mclk_freq) )  
					mclk_div <= mclk_div + 1;
				else
					begin 
						mclk_div <= 0;
						ctrl_mclk <= ~ctrl_mclk;
					end
			end
	end
	
	//ledclk
	always @ (posedge clkin or negedge swt)
	begin
		if (!swt)
			begin
				ledclk_div <= 0;
				ctrl_ledclk <= 0;
			end
		else
			begin
				if (ledclk_div <  (clk_freq/ledclk_freq) )  
					ledclk_div <= ledclk_div + 1;
				else
					begin 
						ledclk_div <= 0;
						ctrl_ledclk <= ~ctrl_ledclk;
					end
			end
	end
	
	assign sclk = ctrl_sclk;
	assign mclk = ctrl_mclk;
	assign ledclk = ctrl_ledclk;
	
	//**********states and stages**************
	reg  [nl2+sts-3:0] state;
	wire [2:0] stage;
	wire [nl2-2:0] cnt;
	assign cnt = state[nl2-2:0];
	assign stage = state[nl2+sts-3:nl2-1];
  
	//**********samples and data**************
	reg signed [7:0] samples[n-1:0];
	reg signed [15:0] data[n-1:0];
	integer i;
	
  	//**********bit reversal operation**************
	wire [4:0] c[31:0];
	wire [4:0] r[31:0];
	genvar k,l;
	generate
		for(k=0;k<32;k=k+1)
			begin:loop1
				assign c[k]=k;
				for(l=0;l<5;l=l+1)
					begin:loop2
						assign r[k][l]=c[k][4-l];
					end
			end
	endgenerate
	
	//**********read address and twiddle factor address*************
	wire[4:0] addr_1;
	wire[4:0] addr_2;
	wire[3:0] TwAddr;
	wire[16:0] tw;
	
	//**********butterfly input selection *************
	wire [15:0] bfin1, bfin2;
	assign bfin1 = data[addr_1],
			 bfin2 = data[addr_2];
			 
	//**********butterfly out *************
	wire [15:0] bfout1, bfout2;
	
	//*********power calculator value**************
	wire [15:0] val;
	wire signed [7:0] re, im;
	wire signed [15:0] re2, im2, sum;
	wire [7:0] aval;
	wire sc;
	assign sc=(stage==nl2+2);
	assign val = data[cnt];
	assign re[7:0] = sc? data[n/2][15:8]:val[15:8]<<1,
			 im[7:0]=sc? data[n/2][7:0]: val[7:0]<<1,
			 re2=re,
			 im2=im,
			 sum=re2*re2+im2*im2,
			 aval=sum[14]?sum[14:7]-1:sum[14:7];
  
	//********output calculation*************
	reg [7:0] summer;
	reg [7:0] outr[8:0];
	wire [7:0] summed;
	assign summed = summer + aval;
  
	//final output
	wire [7:0] cur;
	reg [2:0] cc;
	always @(posedge ledclk)
		begin
			cc <= cc + 1;
		end
	assign cur = outr[cc],
			 column = ~(8'b10_00_00_00>>cc);
	assign row[7]=cur[7];
	genvar m;
	generate
		for(m=0;m<7;m=m+1)
			begin:loop
				assign row[m]=row[m+1]|(cur[m]);
			end
	endgenerate
	//**********initial state**************
	initial 
	begin
		state=(nl2+1)<<(nl2-1);
		cc=0;
		for (i=0;i<n;i=i+1)
			begin
				samples[i]=0;
				data[i]=0;
			end
	end
  
	//**********next state logic**************
	always @(posedge mclk)
		begin
			case (stage)
				0:
					begin
						for(i=0;i<n;i=i+1)
							begin
								data[c[i]]<={samples[r[i]], 8'b0};
							end
						state[nl2+sts-3:nl2-1]<=1;
						state[nl2-2:0]<=0;
					end
        
			4'd7:
          begin
            outr[8]<=summed;
            
            state<=0;
          end
        
        4'd6:
          begin
            case (cnt)
              0:
                summer<=aval;
              1:
                begin
                  outr[0]<=summed;
                  summer<=0;
                end
              2:
                begin
                  outr[1]<=summed;
                  summer<=0;
                end
              3:
                begin
                  outr[2]<=summed;
                  summer<=0;
                end
              4:
                begin
                  outr[3]<=summed;
                  summer<=0;
                end
              5:
                begin
                  outr[4]<=summed;
                  summer<=0;
                end
              6:
              begin
                  outr[5]<=summed;
                  summer<=0;
                end
              7:
                begin
                  outr[6]<=summed;
                  summer<=0;
                end
              8:
                begin
                  outr[7]<=summed;
                  summer<=0;
                end
              default:
                summer<=summed;
              
            endcase
            state <= state + 1;
				end
			default:
				begin
					for(i=0;i<n;i=i+1)
						if(addr_1==i)
							data[i]<=bfout1;
					for(i=0;i<n;i=i+1)
						if(addr_2==i)
							data[i]<=bfout2;
					state<=state+1;
				end
			endcase
		end
	//**********sampling block**************
	always @(negedge sclk) 
		begin
			samples[0] <= in-8'd128;
			for (i=1;i<n;i=i+1)
				samples[i]<=samples[i-1];
		end
		
	 //**********output oscilloscope**************
	 assign gpio[0] = aud_xclk;
	 assign gpio[4] = adcdat;
	 assign gpio[5] = adclrck;
	 assign gpio[6] = i2c_sclk;
	 assign gpio[7] = i2c_sdat; 
	 
endmodule