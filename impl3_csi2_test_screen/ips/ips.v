/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module ips
//
module ips (tx_dphy_byte_data_i, tx_dphy_dt_i, tx_dphy_vc_i, tx_dphy_wc_i, 
            CLKI, CLKOS, int_pll_RST, tx_dphy_byte_clk_o, tx_dphy_byte_data_en_i, 
            tx_dphy_c2d_ready_o, tx_dphy_clk_hs_en_i, tx_dphy_clk_n_o, 
            tx_dphy_clk_p_o, tx_dphy_d0_n_io, tx_dphy_d0_p_io, tx_dphy_d1_n_o, 
            tx_dphy_d1_p_o, tx_dphy_d_hs_en_i, tx_dphy_d_hs_rdy_o, tx_dphy_ld_pyld_o, 
            tx_dphy_lp_en_i, tx_dphy_pd_dphy_i, tx_dphy_pix2byte_rstn_o, 
            tx_dphy_pll_lock_o, tx_dphy_ref_clk_i, tx_dphy_reset_n_i, 
            tx_dphy_sp_en_i, tx_dphy_tinit_done_o) /* synthesis sbp_module=true */ ;
    input [63:0]tx_dphy_byte_data_i;
    input [5:0]tx_dphy_dt_i;
    input [1:0]tx_dphy_vc_i;
    input [15:0]tx_dphy_wc_i;
    input CLKI;
    output CLKOS;
    input int_pll_RST;
    output tx_dphy_byte_clk_o;
    input tx_dphy_byte_data_en_i;
    output tx_dphy_c2d_ready_o;
    input tx_dphy_clk_hs_en_i;
    inout tx_dphy_clk_n_o;
    inout tx_dphy_clk_p_o;
    inout tx_dphy_d0_n_io;
    inout tx_dphy_d0_p_io;
    inout tx_dphy_d1_n_o;
    inout tx_dphy_d1_p_o;
    input tx_dphy_d_hs_en_i;
    output tx_dphy_d_hs_rdy_o;
    output tx_dphy_ld_pyld_o;
    input tx_dphy_lp_en_i;
    input tx_dphy_pd_dphy_i;
    output tx_dphy_pix2byte_rstn_o;
    output tx_dphy_pll_lock_o;
    input tx_dphy_ref_clk_i;
    input tx_dphy_reset_n_i;
    input tx_dphy_sp_en_i;
    output tx_dphy_tinit_done_o;
    
    
    int_pll int_pll_inst (.CLKI(CLKI), .CLKOS(CLKOS), .RST(int_pll_RST));
    tx_dphy tx_dphy_inst (.byte_data_i({tx_dphy_byte_data_i}), .dt_i({tx_dphy_dt_i}), 
            .vc_i({tx_dphy_vc_i}), .wc_i({tx_dphy_wc_i}), .byte_clk_o(tx_dphy_byte_clk_o), 
            .byte_data_en_i(tx_dphy_byte_data_en_i), .c2d_ready_o(tx_dphy_c2d_ready_o), 
            .clk_hs_en_i(tx_dphy_clk_hs_en_i), .clk_n_o(tx_dphy_clk_n_o), 
            .clk_p_o(tx_dphy_clk_p_o), .d0_n_io(tx_dphy_d0_n_io), .d0_p_io(tx_dphy_d0_p_io), 
            .d1_n_o(tx_dphy_d1_n_o), .d1_p_o(tx_dphy_d1_p_o), .d_hs_en_i(tx_dphy_d_hs_en_i), 
            .d_hs_rdy_o(tx_dphy_d_hs_rdy_o), .ld_pyld_o(tx_dphy_ld_pyld_o), 
            .lp_en_i(tx_dphy_lp_en_i), .pd_dphy_i(tx_dphy_pd_dphy_i), .pix2byte_rstn_o(tx_dphy_pix2byte_rstn_o), 
            .pll_lock_o(tx_dphy_pll_lock_o), .ref_clk_i(tx_dphy_ref_clk_i), 
            .reset_n_i(tx_dphy_reset_n_i), .sp_en_i(tx_dphy_sp_en_i), .tinit_done_o(tx_dphy_tinit_done_o));
    
endmodule

