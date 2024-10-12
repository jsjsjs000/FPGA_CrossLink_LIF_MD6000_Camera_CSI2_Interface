//##################################################################################################################
// File Name : Testbench parameter and simulation file
// Purpose   : When user wants to override default TB parameters like number of bytes, lines, frames, etc.
//             
// Type      : This is a verilog file
// Usage     : This file is read via Aldec simulator or any verilog simulator.
//##################################################################################################################

//##################################################################################################################
// Simulation steps:
// 1. Create new project using Lattice Diamond for Windows
// 2. Modify the testbench parameters if needed. Location: \<project_dir>\<core_instance_name>\<core_name>_eval\testbench\tb_setup_params.v
// 3. Open Active-HDL Lattice Edition GUI tool
// 4. Click Tools -> Execute macro, then select the do file (*_run.do)
// 5. Wait for simulation to finish
// 
//##################################################################################################################

//##################################################################################################################
// Testbench Parameters
// Modify/uncomment the `define according to your preference
//##################################################################################################################

// NUM_FRAMES - Used to set the number of video frames
 `define NUM_FRAMES 9

// NUM_LINES - Used to set the number of lines per frame
 `define NUM_LINES 9 

//number of initial bytes/word count /// *** NOTE if PKT_FORMATTER is OFF num_bytes must be k*GEAR*NUM_TX_LANE (ONLY for Test bench) 
 `define NUM_BYTES 40   

// VIRTUAL_CHANNEL - Used to set the virtual channel number
 `define VIRTUAL_CHANNEL 2'h0

 `define TINIT_DURATION        135000000
// DPHY_DEBUG_ON - Used to enable or disable debug messages
//                 0 - debug messages disabled (default if not defined)
//                 1 - debug messages enabled
 `define DPHY_DEBUG_ON 0 

// DSI data type can be set by defining one of the directives (RGB888, RGB666, RGB666_LOOSE)
// CSI-2 data type can be set by defining one of the directives (RAW8, RAW10, RAW12, YUV420_10, YUV420_10_CSPS, YUV420_8, YUV420_8_CSPS, LEGACY_YUV420_8, YUV422_10, YUV422_8, RGB888)
`define TEST_DATA_TYPE "RGB888"

`define DRIVING_EDGE                  1 //1 byte data is driven at positive edge; 0 byte data is driven at negative edge
   // Design parameters
`define PD_CH                         0
   //for CSI2
`define HS_RDY_TO_SP_EN_DLY           10
`define HS_RDY_TO_LP_EN_DLY           10
`define LP_EN_TO_BYTE_DATA_EN_DLY     0
`define HS_RDY_NEG_TO_HS_CLK_EN_DLY   1
`define D_HS_RDY_TO_D_HS_CLK_EN_DLY   10
`define LS_LE_EN                      1
`define GEN_FR_NUM                    0
`define GEN_LN_NUM                    0
   //for DSI
`define HS_RDY_TO_VSYNC_START_DLY     10
`define HS_RDY_TO_HSYNC_START_DLY     10
`define HS_RDY_TO_BYTE_DATA_EN_DLY    10
`define HSYNC_PULSE_FRONT             1
`define HSYNC_PULSE_BACK              1
`define VSYNC_TO_HSYNC_DLY            10
`define HSYNC_TO_HSYNC_DLY            10
   //packet without formatter
`define HS_RDY_TO_DPHY_PKTEN_DLY      2

