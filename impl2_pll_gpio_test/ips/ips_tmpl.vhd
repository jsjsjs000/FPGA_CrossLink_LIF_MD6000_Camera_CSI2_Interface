--VHDL instantiation template

component ips is
    port (CLKI: in std_logic;
        CLKOS: out std_logic;
        int_pll_RST: in std_logic
    );
    
end component ips; -- sbp_module=true 
_inst: ips port map (CLKI => __,CLKOS => __,int_pll_RST => __);
