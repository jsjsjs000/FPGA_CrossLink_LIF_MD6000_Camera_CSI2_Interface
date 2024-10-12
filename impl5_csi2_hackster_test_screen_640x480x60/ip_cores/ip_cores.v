/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module ip_cores
//
module ip_cores (csi2_output_byte_data_i, csi2_output_dt_i, csi2_output_vc_i, 
            csi2_output_wc_i, csi2_output_byte_clk_o, csi2_output_byte_data_en_i, 
            csi2_output_c2d_ready_o, csi2_output_clk_hs_en_i, csi2_output_clk_n_o, 
            csi2_output_clk_p_o, csi2_output_d0_n_io, csi2_output_d0_p_io, 
            csi2_output_d1_n_o, csi2_output_d1_p_o, csi2_output_d_hs_en_i, 
            csi2_output_d_hs_rdy_o, csi2_output_frame_max_i, csi2_output_ld_pyld_o, 
            csi2_output_lp_en_i, csi2_output_pd_dphy_i, csi2_output_pix2byte_rstn_o, 
            csi2_output_pll_lock_o, csi2_output_ref_clk_i, csi2_output_reset_n_i, 
            csi2_output_sp_en_i, csi2_output_tinit_done_o) /* synthesis sbp_module=true */ ;
    input [63:0]csi2_output_byte_data_i;
    input [5:0]csi2_output_dt_i;
    input [1:0]csi2_output_vc_i;
    input [15:0]csi2_output_wc_i;
    output csi2_output_byte_clk_o;
    input csi2_output_byte_data_en_i;
    output csi2_output_c2d_ready_o;
    input csi2_output_clk_hs_en_i;
    inout csi2_output_clk_n_o;
    inout csi2_output_clk_p_o;
    inout csi2_output_d0_n_io;
    inout csi2_output_d0_p_io;
    inout csi2_output_d1_n_o;
    inout csi2_output_d1_p_o;
    input csi2_output_d_hs_en_i;
    output csi2_output_d_hs_rdy_o;
    input csi2_output_frame_max_i;
    output csi2_output_ld_pyld_o;
    input csi2_output_lp_en_i;
    input csi2_output_pd_dphy_i;
    output csi2_output_pix2byte_rstn_o;
    output csi2_output_pll_lock_o;
    input csi2_output_ref_clk_i;
    input csi2_output_reset_n_i;
    input csi2_output_sp_en_i;
    output csi2_output_tinit_done_o;
    
    
    csi2_output csi2_output_inst (.byte_data_i({csi2_output_byte_data_i}), 
            .dt_i({csi2_output_dt_i}), .vc_i({csi2_output_vc_i}), .wc_i({csi2_output_wc_i}), 
            .byte_clk_o(csi2_output_byte_clk_o), .byte_data_en_i(csi2_output_byte_data_en_i), 
            .c2d_ready_o(csi2_output_c2d_ready_o), .clk_hs_en_i(csi2_output_clk_hs_en_i), 
            .clk_n_o(csi2_output_clk_n_o), .clk_p_o(csi2_output_clk_p_o), 
            .d0_n_io(csi2_output_d0_n_io), .d0_p_io(csi2_output_d0_p_io), 
            .d1_n_o(csi2_output_d1_n_o), .d1_p_o(csi2_output_d1_p_o), .d_hs_en_i(csi2_output_d_hs_en_i), 
            .d_hs_rdy_o(csi2_output_d_hs_rdy_o), .frame_max_i(csi2_output_frame_max_i), 
            .ld_pyld_o(csi2_output_ld_pyld_o), .lp_en_i(csi2_output_lp_en_i), 
            .pd_dphy_i(csi2_output_pd_dphy_i), .pix2byte_rstn_o(csi2_output_pix2byte_rstn_o), 
            .pll_lock_o(csi2_output_pll_lock_o), .ref_clk_i(csi2_output_ref_clk_i), 
            .reset_n_i(csi2_output_reset_n_i), .sp_en_i(csi2_output_sp_en_i), 
            .tinit_done_o(csi2_output_tinit_done_o));
    
endmodule

