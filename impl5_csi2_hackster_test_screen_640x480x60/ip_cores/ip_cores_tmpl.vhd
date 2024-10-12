--VHDL instantiation template

component ip_cores is
    port (csi2_output_byte_data_i: in std_logic_vector(63 downto 0);
        csi2_output_dt_i: in std_logic_vector(5 downto 0);
        csi2_output_vc_i: in std_logic_vector(1 downto 0);
        csi2_output_wc_i: in std_logic_vector(15 downto 0);
        csi2_output_byte_clk_o: out std_logic;
        csi2_output_byte_data_en_i: in std_logic;
        csi2_output_c2d_ready_o: out std_logic;
        csi2_output_clk_hs_en_i: in std_logic;
        csi2_output_clk_n_o: inout std_logic;
        csi2_output_clk_p_o: inout std_logic;
        csi2_output_d0_n_io: inout std_logic;
        csi2_output_d0_p_io: inout std_logic;
        csi2_output_d1_n_o: inout std_logic;
        csi2_output_d1_p_o: inout std_logic;
        csi2_output_d_hs_en_i: in std_logic;
        csi2_output_d_hs_rdy_o: out std_logic;
        csi2_output_frame_max_i: in std_logic;
        csi2_output_ld_pyld_o: out std_logic;
        csi2_output_lp_en_i: in std_logic;
        csi2_output_pd_dphy_i: in std_logic;
        csi2_output_pix2byte_rstn_o: out std_logic;
        csi2_output_pll_lock_o: out std_logic;
        csi2_output_ref_clk_i: in std_logic;
        csi2_output_reset_n_i: in std_logic;
        csi2_output_sp_en_i: in std_logic;
        csi2_output_tinit_done_o: out std_logic
    );
    
end component ip_cores; -- sbp_module=true 
_inst: ip_cores port map (csi2_output_byte_data_i => __,csi2_output_dt_i => __,
            csi2_output_vc_i => __,csi2_output_wc_i => __,csi2_output_byte_clk_o => __,
            csi2_output_byte_data_en_i => __,csi2_output_c2d_ready_o => __,
            csi2_output_clk_hs_en_i => __,csi2_output_clk_n_o => __,csi2_output_clk_p_o => __,
            csi2_output_d0_n_io => __,csi2_output_d0_p_io => __,csi2_output_d1_n_o => __,
            csi2_output_d1_p_o => __,csi2_output_d_hs_en_i => __,csi2_output_d_hs_rdy_o => __,
            csi2_output_frame_max_i => __,csi2_output_ld_pyld_o => __,csi2_output_lp_en_i => __,
            csi2_output_pd_dphy_i => __,csi2_output_pix2byte_rstn_o => __,
            csi2_output_pll_lock_o => __,csi2_output_ref_clk_i => __,csi2_output_reset_n_i => __,
            csi2_output_sp_en_i => __,csi2_output_tinit_done_o => __);
