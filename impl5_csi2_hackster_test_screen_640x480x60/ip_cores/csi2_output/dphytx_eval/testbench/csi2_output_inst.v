//===========================================================================
// Verilog file generated by Clarity Designer    10/12/2024    18:06:21  
// Filename  : csi2_output_inst.v                                                
// IP package: CSI-2/DSI D-PHY Transmitter 1.4                           
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================
csi2_output csi2_output_inst (
  .ref_clk_i        (ref_clk_i      ),   // reference clock for D-PHY PLL
  .reset_n_i        (reset_n_i      ),   // (active low) asynchronous reset
  .pd_dphy_i        (pd_dphy_i      ),   // DPHY PD signal
  .byte_data_i      (byte_data_i    ),   // Byte data
  .byte_data_en_i   (byte_data_en_i ),   // Byte data enable
  .sp_en_i          (sp_en_i        ),   // Short packet enable for CSI-2
  .lp_en_i          (lp_en_i        ),   // long packet enable for CSI-2
  .ld_pyld_o        (ld_pyld_o      ),   // Load payload
  .frame_max_i      (frame_max_i    ),   // Maximum number of frame counter
  .vc_i             (vc_i           ),   // Virtual channel
  .dt_i             (dt_i           ),   // Data type
  .wc_i             (wc_i           ),   // Word count
  .tinit_done_o     (tinit_done_o   ),   // Tinit done
  .pll_lock_o       (pll_lock_o     ),   // PLL clock lock signal
  .pix2byte_rstn_o  (pix2byte_rstn_o),
  .clk_hs_en_i       (clk_hs_en_i    ),  // Handshaking for Rx/Tx
  .d_hs_en_i         (d_hs_en_i      ),
  .d_hs_rdy_o        (d_hs_rdy_o     ),
  .c2d_ready_o       (c2d_ready_o    ),

  .d0_p_io           (d0_p_io        ),  // D-PHY output data 0
  .d0_n_io           (d0_n_io        ),  // D-PHY output data 0
  .d1_p_o            (d1_p_o         ),  // D-PHY output data 1
  .d1_n_o            (d1_n_o         ),  // D-PHY output data 1
  .clk_p_o           (clk_p_o        ),  // DPHY output clock
  .clk_n_o           (clk_n_o        ),  // DPHY output clock
  .byte_clk_o        (byte_clk_o     )   // Byte clock from D-PHY PLL
);


