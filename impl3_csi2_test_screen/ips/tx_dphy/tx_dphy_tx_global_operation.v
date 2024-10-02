//===========================================================================
// Verilog file generated by Clarity Designer    10/02/2024    19:39:36  
// Filename  : tx_dphy_tx_global_operation.v                                                
// IP package: CSI-2/DSI D-PHY Transmitter 1.4                           
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================

module tx_dphy_tx_global_operation (
input  wire                       clk_hs_en_i,
input  wire                       d_hs_en_i,
output wire                       d_hs_rdy_o,
input  wire                       reset_n,
input  wire                       core_clk,
input  wire                       dphy_pkten_i,
input  wire [4*16-1:0] dphy_pkt_i,
output wire                       hs_clk_gate_en_o,
output wire                       hs_clk_en_o,
output wire                       hs_data_en_o,
output wire   [16-1:0] hs_data_d3_o,
output wire   [16-1:0] hs_data_d2_o,
output wire   [16-1:0] hs_data_d1_o,
output wire   [16-1:0] hs_data_d0_o,
output wire                       c2d_ready_o,
output wire                       lp_clk_en_o,
output wire                       lp_clk_p_o,
output wire                       lp_clk_n_o,
output wire                       lp_data_en_o,
output wire                       lp_data_p_o,
output wire                       lp_data_n_o
);

tx_global_operation # (
  .USER_TIMING      ("OFF"),
  .T_LPX            (0),
  .T_CLKPREP        (0),
  .T_CLK_HSZERO     (0),
  .T_CLKPRE         (0),
  .T_CLKPOST        (0),
  .T_CLKTRAIL       (0),
  .T_CLKEXIT        (0),
  .T_DATPREP        (0),
  .T_DAT_HSZERO     (0),
  .T_DATTRAIL       (0),
  .T_DATEXIT        (0),
  .CLK_MODE         ("HS_LP"),
  .LANE_WIDTH       (2),
  .DATA_WIDTH       (16),
  .TX_GEAR          (8),
  .TX_FREQ_TGT      (25),
  .PKT_FORMATTER    ("ON")
)
u_tx_global_operation (
  .clk_hs_en_i      (clk_hs_en_i),
  .d_hs_en_i        (d_hs_en_i),
  .d_hs_rdy_o       (d_hs_rdy_o),
  .reset_n          (reset_n),
  .core_clk         (core_clk),
  .dphy_pkten_i     (dphy_pkten_i),
  .dphy_pkt_i       (dphy_pkt_i),
  .hs_clk_gate_en_o (hs_clk_gate_en_o),
  .hs_clk_en_o      (hs_clk_en_o),
  .hs_data_en_o     (hs_data_en_o),
  .hs_data_d3_o     (hs_data_d3_o),
  .hs_data_d2_o     (hs_data_d2_o),
  .hs_data_d1_o     (hs_data_d1_o),
  .hs_data_d0_o     (hs_data_d0_o),
  .c2d_ready_o      (c2d_ready_o),
  .lp_clk_en_o      (lp_clk_en_o),
  .lp_clk_p_o       (lp_clk_p_o),
  .lp_clk_n_o       (lp_clk_n_o),
  .lp_data_en_o     (lp_data_en_o),
  .lp_data_p_o      (lp_data_p_o),
  .lp_data_n_o      (lp_data_n_o)
);

endmodule


