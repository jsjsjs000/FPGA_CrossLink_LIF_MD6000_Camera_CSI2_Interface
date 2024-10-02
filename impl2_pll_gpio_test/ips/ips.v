/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module ips
//
module ips (CLKI, CLKOS, int_pll_RST) /* synthesis sbp_module=true */ ;
    input CLKI;
    output CLKOS;
    input int_pll_RST;
    
    
    int_pll int_pll_inst (.CLKI(CLKI), .CLKOS(CLKOS), .RST(int_pll_RST));
    
endmodule

