//===========================================================================
// Verilog file generated by Clarity Designer    10/12/2024    19:35:07  
// Filename  : csi2_output_tinit_count.v                                                
// IP package: CSI-2/DSI D-PHY Transmitter 1.4                           
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================

module csi2_output_tinit_count (
input  wire clk,
input  wire resetn,
output wire tinit_done_o
);

tinit_count #(
  .TINIT_VALUE  (1000)
)
u_tinit_count (
  .clk          (clk),
  .resetn       (resetn),
  .tinit_done_o (tinit_done_o)
);

endmodule


