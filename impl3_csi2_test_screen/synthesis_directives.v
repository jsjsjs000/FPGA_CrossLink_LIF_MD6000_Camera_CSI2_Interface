//----Video Data Type----
`define    RGB888
//`define    RAW8
//`define    RAW10
//`define    RAW12

//----Number of Tx Lane----
`define    NUM_TX_LANE_2

//----Number of Pixel Per Clock---
`define    NUM_PIX_LANE_1

//---Tx Gear---
`define    TX_GEAR_8

`define    MISC_ON

//----Clock Mode----
`define    CLK_MODE_HS_LP    // clock mode non-continuous
//`define    CLK_MODE_HS_ONLY  // clock mode continuous

//---Virtual Channel---
`define	   VC			 2'b00

`define    NUM_PIXELS   640

//===================================
// DO NOT MODIFY
//===================================

`ifdef RGB888
	`define PIX_WIDTH  24
	`define DT         6'h24
`elsif RAW8
	`define PIX_WIDTH  8
	`define DT         6'h2A
`elsif RAW10
	`define PIX_WIDTH  10
	`define DT         6'h2B
`elsif RAW12
	`define PIX_WIDTH  12
	`define DT         6'h2C
`endif

`define NUM_PIX_LANE   1

`ifdef NUM_TX_LANE_1
	`define NUM_TX_LANE	 1
`elsif NUM_TX_LANE_2
	`define NUM_TX_LANE	 2
`elsif NUM_TX_LANE_4
	`define NUM_TX_LANE	 4
`endif
