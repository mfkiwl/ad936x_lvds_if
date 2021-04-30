// -----------------------------------------------------------------------------
// Copyright (c) 2019-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author 	 : WCC 1530604142@qq.com
// File   	 : ad9363_lvds_if_tx
// Create 	 : 2021-04-30
// Revise 	 : 2021-
// Editor 	 : Vscode, tab size (4)
// Functions : This module Transmit data to ad9363 throgh phy interface.Get the source 
// 			   data from user logic
// 			   
// -----------------------------------------------------------------------------

module ad9363_lvds_if_tx(
	input 	wire 			ref_clk 	,//200M reference clock
	input 	wire 			data_clk	,//drive user logic
	input 	wire 			rst 	 	,
	//====================================================
  	//ad9363 receive  phy interface 
  	//====================================================
  	output 	wire 			tx_clk_out 	,
  	output 	wire 			tx_frame_out,
  	output 	wire  [11:0]	tx_data_out ,
  	//====================================================
	//ad9363 transmitter user logic interface 
	//====================================================
	input 	wire 			dac_valid	,
	input 	wire 	[11:0]	dac_data_i1	,
	input 	wire 	[11:0]	dac_data_q1	
	);

//====================================================
//internal signal and registers
//====================================================
wire 	[1:0]	tx_frame 		;


assign tx_frame = (dac_valid == 1'b1) ? 2'b10 : 2'b00; 

genvar i;
//====================================================
//Send IQ data and frame signal
//====================================================

ODDR #(
  	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  	.INIT(1'b0),    			// Initial value of Q: 1'b0 or 1'b1
  	.SRTYPE("SYNC") 			// Set/Reset type: "SYNC" or "ASYNC" 
) 	ODDR_inst_frame (
  	.Q(tx_frame_out),       // 1-bit DDR output
  	.C(data_clk),   	    // 1-bit clock input
  	.CE(1'b1), 			    // 1-bit clock enable input
  	.D1(tx_frame[1]), 	    // 1-bit data input (positive edge)
  	.D2(tx_frame[0]), 	    // 1-bit data input (negative edge)
  	.R(1'b0),   		    // 1-bit reset
  	.S(1'b0)    		    // 1-bit set
);     

ODDR #(
  	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  	.INIT(1'b0),    			// Initial value of Q: 1'b0 or 1'b1
  	.SRTYPE("SYNC") 			// Set/Reset type: "SYNC" or "ASYNC" 
) 	ODDR_inst_clock (
  	.Q(tx_clk_out),   	// 1-bit DDR output
  	.C(data_clk),   	// 1-bit clock input
  	.CE(1'b1), 			// 1-bit clock enable input
  	.D1(1'b1), 			// 1-bit data input (positive edge)
  	.D2(1'b0), 			// 1-bit data input (negative edge)
  	.R(1'b0),   		// 1-bit reset
  	.S(1'b0)    		// 1-bit set
);

generate
	for (i = 0; i < 12; i = i + 1) begin
		ODDR #(
		  	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
		  	.INIT(1'b0),    			// Initial value of Q: 1'b0 or 1'b1
		  	.SRTYPE("SYNC") 			// Set/Reset type: "SYNC" or "ASYNC" 
		) 	ODDR_inst_clock (
		  	.Q(tx_data_out[i]),   		// 1-bit DDR output
		  	.C(data_clk),   			// 1-bit clock input
		  	.CE(1'b1), 					// 1-bit clock enable input
		  	.D1(dac_data_i1[i]), 		// 1-bit data input (positive edge)
		  	.D2(dac_data_q1[i]), 		// 1-bit data input (negative edge)
		  	.R(1'b0),   				// 1-bit reset
		  	.S(1'b0)    				// 1-bit set
		);
	end
endgenerate

endmodule
