//Verilog instantiation template

ips _inst (.tx_dphy_byte_data_i(), .tx_dphy_dt_i(), .tx_dphy_vc_i(), .tx_dphy_wc_i(), 
    .tx_dphy_byte_clk_o(), .tx_dphy_byte_data_en_i(), .tx_dphy_c2d_ready_o(), 
    .tx_dphy_clk_hs_en_i(), .tx_dphy_clk_n_o(), .tx_dphy_clk_p_o(), .tx_dphy_d0_n_io(), 
    .tx_dphy_d0_p_io(), .tx_dphy_d1_n_o(), .tx_dphy_d1_p_o(), .tx_dphy_d_hs_en_i(), 
    .tx_dphy_d_hs_rdy_o(), .tx_dphy_ld_pyld_o(), .tx_dphy_lp_en_i(), .tx_dphy_pd_dphy_i(), 
    .tx_dphy_pix2byte_rstn_o(), .tx_dphy_pll_lock_o(), .tx_dphy_ref_clk_i(), 
    .tx_dphy_reset_n_i(), .tx_dphy_sp_en_i(), .tx_dphy_tinit_done_o(), 
    .CLKI(), .CLKOS(), .int_pll_RST(), .p2b_byte_data_o(), .p2b_data_type_o(), 
    .p2b_pix_data0_i(), .p2b_byte_clk_i(), .p2b_byte_en_o(), .p2b_c2d_ready_i(), 
    .p2b_dvalid_i(), .p2b_fv_end_o(), .p2b_fv_i(), .p2b_fv_start_o(), 
    .p2b_lv_end_o(), .p2b_lv_i(), .p2b_lv_start_o(), .p2b_pix_clk_i(), 
    .p2b_rst_n_i(), .p2b_txfr_en_i(), .p2b_txfr_req_o());