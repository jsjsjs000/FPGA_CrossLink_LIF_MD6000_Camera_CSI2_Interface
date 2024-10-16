//===========================================================================
// Verilog file generated by Clarity Designer    10/12/2024    19:35:07  
// Filename  : csi2_output_pkt_formatter_bb.v                                                
// IP package: CSI-2/DSI D-PHY Transmitter 1.4                           
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================

module csi2_output_pkt_formatter (
input  wire                       reset_n,
input  wire                       core_clk,
input  wire                 [1:0] vc_i,
input  wire                 [5:0] dt_i,
input  wire                [15:0] wc_i,
input  wire                       vsync_start_i,
input  wire                       hsync_start_i,
input  wire                       sp_en_i,
input  wire                       lp_en_i,
input  wire                 [7:0] frame_max_i,
input  wire [4*16-1:0] byte_data_i,
input  wire                       byte_data_en_i,
output wire [4*16-1:0] dphy_pkt_o,
output wire                       dphy_pkten_o,
input  wire                       d_hs_rdy_i,
output wire                       ld_pyld_o,
output wire                       pix2byte_rstn_o
);

endmodule


