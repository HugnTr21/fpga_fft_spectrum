 /////////////////////////////////
/// audio interface to DE1-SoC ///
/// March 2016                 ///
/// serial transfer  ADC       ///
/// part 2 serial module       ///
//////////////////////////////////

module S2P (
 
 serial_adc,	// 24 bit serial in data
 PADCL,			// left channel ADC
 PADCR,			// right channel ADC 
 adc_lr,			// left right enable
 clk,				// 50 KHz clock
 enable			// master reset

);

 
 output[16:0] PADCL;	// Serial shift register ADC left
 output[16:0] PADCR;	// Serial shift register ADC right
 
 reg[16:0] PADCL;
 reg[16:0] PADCR;
 
 input serial_adc; 
 input clk;
 input enable;
 input adc_lr;
 
///////////////////////////////////////
// internal register
///////////////////////////////////////
  
 reg [4:0] PADCL_counter;	// counter for serial in register
 reg [4:0] PADCR_counter;	// indicates end of 3 bit transfer

 
 ////////////////////////////////////////
 // state machine for serial counter   // 
 ////////////////////////////////////////
 
	always @(negedge enable or posedge clk) 
	begin
		if  (!enable)
			begin
				PADCR_counter = 4'b0; // reset right channel counter
			end
		else 
			begin
				if (!adc_lr) 
					PADCR_counter = 4'b0;
				else
					PADCR_counter = PADCR_counter + 1; // right channel captures audio
			end
	end
//////////////////////////////////////////////////////////////

	always @(negedge enable or posedge clk) 
	begin
		if  (!enable)
			begin
				PADCL_counter = 4'b0; // reset left channel counter
			end
		else 
			begin
				if (adc_lr) 
					PADCL_counter = 4'b0;
				else
					PADCL_counter = PADCL_counter + 1; // left channel captures audio
				end
			end
 
 always @ (negedge enable or negedge clk) begin
 case (PADCL_counter)
 
		// msb first
		7'd0	: begin PADCL[16] = serial_adc ;  end // bit 0 - start
		7'd1	: begin PADCL[15] = serial_adc ;  end // valid audio 15 left channel
		7'd2	: begin PADCL[14] = serial_adc ;  end // valid audio 14 left channel
		7'd3	: begin PADCL[13] = serial_adc ;  end // valid audio 13 left channel
		7'd4	: begin PADCL[12] = serial_adc ;  end // valid audio 12 left channel
		7'd5	: begin PADCL[11] = serial_adc ;  end // valid audio 11 left channel		
		7'd6	: begin PADCL[10] = serial_adc ;  end // valid audio 10 left channel
		7'd7	: begin PADCL[9] = serial_adc ;  end // valid audio 9 left channel
		7'd8	: begin PADCL[8] = serial_adc ;  end // valid audio 8 left channel
		7'd9	: begin PADCL[7] = serial_adc ;  end // valid audio 7 left channel
		7'd10:  begin PADCL[6] = serial_adc ;  end // valid audio 6 left channel
		7'd11 : begin PADCL[5] = serial_adc ;  end // valid audio 5 left channel
		7'd12	: begin PADCL[4] = serial_adc ;  end // valid audio 4 left channel
		7'd13	: begin PADCL[3] = serial_adc ;  end // valid audio 3 left channel
		7'd14	: begin PADCL[2] = serial_adc ;  end // valid audio 2 left channel
		7'd15	: begin PADCL[1] = serial_adc ;  end // valid audio 1 left channel
		7'd16	: begin PADCL[0] = serial_adc ;  end // valid audio 0 left channel
		endcase
		
		end
		
always @ (negedge enable or negedge clk) begin
 case (PADCR_counter)
		// msb first
		7'd0	: begin PADCR[16] = serial_adc ;  end // bit 0 - start
		7'd1	: begin PADCR[15] = serial_adc ;  end // valid audio 15 right channel
		7'd2	: begin PADCR[14] = serial_adc ;  end // valid audio 14 right channel
		7'd3	: begin PADCR[13] = serial_adc ;  end // valid audio 13 right channel
		7'd4	: begin PADCR[12] = serial_adc ;  end // valid audio 12 right channel
		7'd5	: begin PADCR[11] = serial_adc ;  end // valid audio 11 right channel
		7'd6	: begin PADCR[10] = serial_adc ;  end // valid audio 10 right channel
		7'd7	: begin PADCR[9] = serial_adc ;  end // valid audio 9 right channel
		7'd8	: begin PADCR[8] = serial_adc ;  end // valid audio 8 right channel		
		7'd9	: begin PADCR[7] = serial_adc ;  end // valid audio 7 right channel		
		7'd10	: begin PADCR[6] = serial_adc ;  end // valid audio 6 right channel		
		7'd11 : begin PADCR[5] = serial_adc ;  end // valid audio 5 right channel		
		7'd12	: begin PADCR[4] = serial_adc ;  end // valid audio 4 right channel		
		7'd13	: begin PADCR[3] = serial_adc ;  end // valid audio 3 right channel		
		7'd14	: begin PADCR[2] = serial_adc ;  end // valid audio 2 right channel		
		7'd15	: begin PADCR[1] = serial_adc ;  end // valid audio 1 right channel		
		7'd16	: begin PADCR[0] = serial_adc ;  end // valid audio 0 right channel
		endcase
		end
		endmodule
