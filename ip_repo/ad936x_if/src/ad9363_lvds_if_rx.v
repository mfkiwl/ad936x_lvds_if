// -----------------------------------------------------------------------------
// Copyright (c) 2019-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author 	 : WCC 1530604142@qq.com
// File   	 : ad9363_lvds_if_rx
// Create 	 : 2021-04-30
// Revise 	 : 2021-
// Editor 	 : Vscode, tab size (4)
// Functions : This module receive data from ad9363 through phy interface. Pass 
// 			   the IQ data into user logic.			   
// -----------------------------------------------------------------------------

module ad9363_cmos_if_rx(
	input 	wire 			ref_clk 	,
	input 	wire 			rst 		,
	//====================================================
	//ad9363 receive  phy interface 
	//====================================================
	input	wire          	rx_clk_in_p		,
	input	wire          	rx_clk_in_n		,
  	input	wire          	rx_frame_in_p	,
	input	wire          	rx_frame_in_n	,
  	input	wire  [5:0]  	rx_data_in_p	,
	input	wire  [5:0]  	rx_data_in_n	,  
	//====================================================
	//ad9363 receive user logic interface 
	//====================================================
	output	wire 			adc_valid	,
	output	wire 	[11:0]	adc_data_i1	,
	output	wire 	[11:0]	adc_data_q1	,
	output 	wire 			rx_status 	,//Tell user the receive data is right or not	
	//====================================================
	//user control signal
	//====================================================
	output 	wire 			rx_data_clk ,//rx_data_clk, from ad9363 to drive user logic
	output 	wire 			tx_data_clk ,//tx_data_clk, to drive user tx logic
	input 	wire 	[4:0]	delay_value	,//delay_value of the IDELAY_CTRL2
	input 	wire 			delay_load_en,//enable data delay load
	input 	wire 			data_clk_ce  //clock enable, only when this signal is valid,
										 //the data_clk can be valid
	);

//====================================================
//internal signals and registers
//====================================================

//buffer the input signal
wire 			rx_clk_bufg		;

//delay the input clock
wire 			rx_clk_delay 	;
wire 	[11:0]	rx_data_delay	;
wire 			rx_frame_delay 	;

//iddr output
wire 	[1:0] 	rx_frame 		;
wire 	[11:0]	rx_data_i 		;
wire 	[11:0]	rx_data_q 		;

//user logic output
reg 			adc_valid_r 	;
reg 	[11:0]	adc_data_i1_r 	;
reg 	[11:0]	adc_data_q1_r 	;

wire 			rdy 			;

genvar i;


//====================================================
//assign output signal
//====================================================
assign rx_data_clk = rx_clk_bufg;
assign tx_data_clk = rx_clk_bufg;
assign adc_valid = adc_valid_r;
assign adc_data_i1 = adc_data_i1_r;
assign adc_data_q1 = adc_data_q1_r;


IDELAYCTRL IDELAYCTRL_inst (
  	.RDY(rdy),       // 1-bit output: Ready output
  	.REFCLK(ref_clk),// 1-bit input: Reference clock input
  	.RST(rst)        // 1-bit input: Active high reset input
);

//====================================================
//buffer the input  clock
//====================================================
BUFGCE BUFGCE_inst (
  	.O(rx_clk_bufg),  // 1-bit output: Clock output
  	.CE(data_clk_ce), // 1-bit input: Clock enable input for I0
  	.I(rx_clk_in)     // 1-bit input: Primary clock
);


//====================================================
//delay the input data
//====================================================
IDELAYE2 #(
  	.CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
  	.DELAY_SRC("IDATAIN"),            // Delay input (IDATAIN, DATAIN)
  	.HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
  	.IDELAY_TYPE("VAR_LOAD"),        // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
  	.IDELAY_VALUE(0),                // Input delay tap setting (0-31)
  	.PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
  	.REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
  	.SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
)
IDELAYE2_inst_frame_delay (
  	.CNTVALUEOUT(), 			// 5-bit output: Counter value output
  	.DATAOUT(rx_frame_delay),	// 1-bit output: Delayed data output
  	.C(ref_clk),	        	// 1-bit input: Clock input
  	.CE(1'b0),                 	// 1-bit input: Active high enable increment/decrement input
  	.CINVCTRL(1'b0),           	// 1-bit input: Dynamic clock inversion input
  	.CNTVALUEIN(delay_value),  	// 5-bit input: Counter value input
  	.DATAIN(1'b0),       		// 1-bit input: Internal delay data input
  	.IDATAIN(rx_frame_in),    	// 1-bit input: Data input from the I/O
  	.INC(1'b0),                	// 1-bit input: Increment / Decrement tap delay input
  	.LD(delay_load_en),     	// 1-bit input: Load IDELAY_VALUE input
  	.LDPIPEEN(1'b0),           	// 1-bit input: Enable PIPELINE register to load data input
  	.REGRST(1'b0)              	// 1-bit input: Active-high reset tap-delay input
);

generate
	for (i = 0; i < 12; i = i + 1) begin
		IDELAYE2 #(
	  	.CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
	  	.DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
	  	.HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
	  	.IDELAY_TYPE("VAR_LOAD"),        // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
	  	.IDELAY_VALUE(0),                // Input delay tap setting (0-31)
	  	.PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
	  	.REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
	  	.SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
	)
	IDELAYE2_inst_frame_delay (
	  	.CNTVALUEOUT(), 			// 5-bit output: Counter value output
	  	.DATAOUT(rx_data_delay[i]),	// 1-bit output: Delayed data output
	  	.C(ref_clk),	        	// 1-bit input: Clock input
	  	.CE(1'b0),                 	// 1-bit input: Active high enable increment/decrement input
	  	.CINVCTRL(1'b0),           	// 1-bit input: Dynamic clock inversion input
	  	.CNTVALUEIN(delay_value),   // 5-bit input: Counter value input
	  	.DATAIN(1'b0),     			// 1-bit input: Internal delay data input
	  	.IDATAIN(rx_data_in[i]),    // 1-bit input: Data input from the I/O
	  	.INC(1'b0),                	// 1-bit input: Increment / Decrement tap delay input
	  	.LD(delay_load_en),     	// 1-bit input: Load IDELAY_VALUE input
	  	.LDPIPEEN(1'b0),           	// 1-bit input: Enable PIPELINE register to load data input
	  	.REGRST(1'b0)              	// 1-bit input: Active-high reset tap-delay input
	);
	end
endgenerate


//====================================================
//Get the IQ data and Frame data
//====================================================
IDDR #(
  	.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
  	                                //    or "SAME_EDGE_PIPELINED" 
  	.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
  	.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
  	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) 	IDDR_inst_frame (
  	.Q1(rx_frame[1]), 	// 1-bit output for positive edge of clock
  	.Q2(rx_frame[0]), 	// 1-bit output for negative edge of clock
  	.C(rx_clk_bufg),   	// 1-bit clock input
  	.CE(1'b1), 			// 1-bit clock enable input
  	.D(rx_frame_delay), // 1-bit DDR data input
  	.R(1'b0),   		// 1-bit reset
  	.S(1'b0)    		// 1-bit set
);	

generate
	for (i = 0; i < 12; i = i + 1)
	begin:data_iddr
		IDDR #(
		  	.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
		  	                                //    or "SAME_EDGE_PIPELINED" 
		  	.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
		  	.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
		  	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		) 	IDDR_inst_data (
		  	.Q1(rx_data_i[i]), 		// 1-bit output for positive edge of clock
		  	.Q2(rx_data_q[i]), 		// 1-bit output for negative edge of clock
		  	.C(rx_clk_bufg),   		// 1-bit clock input
		  	.CE(1'b1), 				// 1-bit clock enable input
		  	.D(rx_data_delay[i]),  	// 1-bit DDR data input
		  	.R(1'b0),   			// 1-bit reset
		  	.S(1'b0)    			// 1-bit set
		);			
	end
endgenerate	

//====================================================
//Get the user IQ data
//====================================================
always @(posedge rx_clk_bufg) begin
	if (rst==1'b1) begin
		adc_valid_r <= 1'b0;
	end
	//Receive frame signal stands for the IQ order 1-->I 0--->Q
	else if (rx_frame == 2'b10) begin
		adc_valid_r <= 1'b1;
	end
	else begin
		adc_valid_r <= 1'b0;
	end
end

always @(posedge rx_clk_bufg) begin
	if (rst==1'b1) begin
		adc_data_i1_r <= 'd0;
		adc_data_q1_r <= 'd0;	
	end
	else if (rx_frame == 2'b10) begin
		adc_data_i1_r <= rx_data_i;
		adc_data_q1_r <= rx_data_q;
	end
	else begin
		adc_data_i1_r <= 'd0;
		adc_data_q1_r <= 'd0;	
	end
end

endmodule
