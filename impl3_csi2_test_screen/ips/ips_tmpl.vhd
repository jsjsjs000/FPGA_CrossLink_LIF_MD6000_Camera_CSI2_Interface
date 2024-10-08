--VHDL instantiation template

component ips is
    port (p2b_byte_data_o: out std_logic_vector(63 downto 0);
        p2b_data_type_o: out std_logic_vector(5 downto 0);
        p2b_pix_data0_i: in std_logic_vector(23 downto 0);
        tx_dphy_byte_data_i: in std_logic_vector(63 downto 0);
        tx_dphy_dt_i: in std_logic_vector(5 downto 0);
        tx_dphy_vc_i: in std_logic_vector(1 downto 0);
        tx_dphy_wc_i: in std_logic_vector(15 downto 0);
        CLKI: in std_logic;
        CLKOS: out std_logic;
        int_pll_RST: in std_logic;
        p2b_byte_clk_i: in std_logic;
        p2b_byte_en_o: out std_logic;
        p2b_c2d_ready_i: in std_logic;
        p2b_dvalid_i: in std_logic;
        p2b_fv_end_o: out std_logic;
        p2b_fv_i: in std_logic;
        p2b_fv_start_o: out std_logic;
        p2b_lv_end_o: out std_logic;
        p2b_lv_i: in std_logic;
        p2b_lv_start_o: out std_logic;
        p2b_pix_clk_i: in std_logic;
        p2b_rst_n_i: in std_logic;
        p2b_txfr_en_i: in std_logic;
        p2b_txfr_req_o: out std_logic;
        tx_dphy_byte_clk_o: out std_logic;
        tx_dphy_byte_data_en_i: in std_logic;
        tx_dphy_c2d_ready_o: out std_logic;
        tx_dphy_clk_hs_en_i: in std_logic;
        tx_dphy_clk_n_o: inout std_logic;
        tx_dphy_clk_p_o: inout std_logic;
        tx_dphy_d0_n_io: inout std_logic;
        tx_dphy_d0_p_io: inout std_logic;
        tx_dphy_d1_n_o: inout std_logic;
        tx_dphy_d1_p_o: inout std_logic;
        tx_dphy_d_hs_en_i: in std_logic;
        tx_dphy_d_hs_rdy_o: out std_logic;
        tx_dphy_ld_pyld_o: out std_logic;
        tx_dphy_lp_en_i: in std_logic;
        tx_dphy_pd_dphy_i: in std_logic;
        tx_dphy_pix2byte_rstn_o: out std_logic;
        tx_dphy_pll_lock_o: out std_logic;
        tx_dphy_ref_clk_i: in std_logic;
        tx_dphy_reset_n_i: in std_logic;
        tx_dphy_sp_en_i: in std_logic;
        tx_dphy_tinit_done_o: out std_logic
    );
    
end component ips; -- sbp_module=true 
_inst: ips port map (tx_dphy_byte_data_i => __,tx_dphy_dt_i => __,tx_dphy_vc_i => __,
          tx_dphy_wc_i => __,tx_dphy_byte_clk_o => __,tx_dphy_byte_data_en_i => __,
          tx_dphy_c2d_ready_o => __,tx_dphy_clk_hs_en_i => __,tx_dphy_clk_n_o => __,
          tx_dphy_clk_p_o => __,tx_dphy_d0_n_io => __,tx_dphy_d0_p_io => __,
          tx_dphy_d1_n_o => __,tx_dphy_d1_p_o => __,tx_dphy_d_hs_en_i => __,
          tx_dphy_d_hs_rdy_o => __,tx_dphy_ld_pyld_o => __,tx_dphy_lp_en_i => __,
          tx_dphy_pd_dphy_i => __,tx_dphy_pix2byte_rstn_o => __,tx_dphy_pll_lock_o => __,
          tx_dphy_ref_clk_i => __,tx_dphy_reset_n_i => __,tx_dphy_sp_en_i => __,
          tx_dphy_tinit_done_o => __,CLKI => __,CLKOS => __,int_pll_RST => __,
          p2b_byte_data_o => __,p2b_data_type_o => __,p2b_pix_data0_i => __,
          p2b_byte_clk_i => __,p2b_byte_en_o => __,p2b_c2d_ready_i => __,
          p2b_dvalid_i => __,p2b_fv_end_o => __,p2b_fv_i => __,p2b_fv_start_o => __,
          p2b_lv_end_o => __,p2b_lv_i => __,p2b_lv_start_o => __,p2b_pix_clk_i => __,
          p2b_rst_n_i => __,p2b_txfr_en_i => __,p2b_txfr_req_o => __);
