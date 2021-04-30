// -----------------------------------------------------------------------------
// Copyright (c) 2019-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author 	 : WCC 1530604142@qq.com
// File   	 : ad9363_lvds_if.v
// Create 	 : 2020-11-19 
// Revise 	 : 2021-04-30 
// Editor 	 : sublime text3, tab size (4)
// Functions : ad9363 interface is used send or receive data between ad9363 and
// 			   user logic. The receive mode of ad9363 is 1R1T lvds
// -----------------------------------------------------------------------------
module ad9363_lvds_if(
	input 	wire 			ref_clk 	,//200M clock for iodelay
	input 	wire 			rst 		,//system reset
	//====================================================
	//physical interface (receive-cmos)
	//====================================================
	input	wire          	rx_clk_in_p		,
	input	wire          	rx_clk_in_n		,
  	input	wire          	rx_frame_in_p	,
	input	wire          	rx_frame_in_n	,
  	input	wire  [5:0]  	rx_data_in_p	,
	input	wire  [5:0]  	rx_data_in_n	,  

  	//====================================================
  	//physical interface (transmit-cmos)
  	//====================================================
  	output 	wire 			tx_clk_out_p 	,
	output 	wire 			tx_clk_out_n 	,
  	output 	wire 			tx_frame_out_p	,
	output 	wire 			tx_frame_out_n	,
  	output 	wire  [5:0]		tx_data_out_p 	,
	output 	wire  [5:0]		tx_data_out_n 	,

  	//====================================================
  	//user rx port
  	//====================================================
  	output	wire 			adc_valid	,
	output	wire 	[11:0]	adc_data_i1	,
	output	wire 	[11:0]	adc_data_q1	,
	output 	wire 			rx_status 	,//Tell user the receive data is right or not

	//====================================================
	//user tx port
	//====================================================
	input 	wire 			dac_valid	,
	input 	wire 	[11:0]	dac_data_i1	,
	input 	wire 	[11:0]	dac_data_q1	,

	//====================================================
	//user control signal
	//====================================================
	output 	wire 			user_clk 		,//user_tx_clk, from ad9363 to drive user transmit logic
	input 	wire 	[4:0]	rx_delay_value	,//delay_value of the IDELAY_CTRL2
	input 	wire 			rx_delay_load_en,//enable data delay load
	input 	wire 			data_clk_ce  	 //clock enable, only when this signal is valid,
										 	 //the user_clk can be valid
	);
//====================================================
//interna signals and registers
//====================================================
wire 			rx_data_clk 	;
wire 			tx_data_clk 	;


assign user_clk = rx_data_clk;

	ad9363_cmos_if_rx inst_ad9363_cmos_if_rx(
		.ref_clk      (ref_clk),
		.rst          (rst),
		.rx_clk_in    (rx_clk_in),
		.rx_frame_in  (rx_frame_in),
		.rx_data_in   (rx_data_in),
		.adc_valid    (adc_valid),
		.adc_data_i1  (adc_data_i1),
		.adc_data_q1  (adc_data_q1),
		.rx_status    (rx_status),
		.rx_data_clk  (rx_data_clk),
		.tx_data_clk  (tx_data_clk),
		.delay_value  (rx_delay_value),
		.delay_load_en(rx_delay_load_en),
		.data_clk_ce  (data_clk_ce)
	);


	ad9363_cmos_if_tx inst_ad9363_cmos_if_tx(
		.ref_clk       (ref_clk),
		.data_clk      (tx_data_clk),
		.rst           (rst),
		.tx_clk_out    (tx_clk_out),
		.tx_frame_out  (tx_frame_out),
		.tx_data_out   (tx_data_out),
		.dac_valid     (dac_valid),
		.dac_data_i1   (dac_data_i1),
		.dac_data_q1   (dac_data_q1)
	);


endmodule